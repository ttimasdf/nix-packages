/*
 * Disable QGraphicsDropShadowEffect rendering in WeMeet's bundled Qt.
 *
 * QGraphicsDropShadowEffect::draw() is reached through a vtable entry, so
 * ordinary LD_PRELOAD symbol interposition does not replace it reliably. This
 * shim resolves the Qt symbols from the already-loaded Qt library and replaces
 * only the matching vtable slot with QGraphicsEffect::drawSource().
 */

#define _GNU_SOURCE

#include <dlfcn.h>
#include <elf.h>
#include <errno.h>
#include <link.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define QT_WIDGETS_SONAME "libQt5Widgets.so.5"
#define QT_SYMBOL_VERSION "Qt_5"
#define DROP_SHADOW_VTABLE "_ZTV25QGraphicsDropShadowEffect"
#define DROP_SHADOW_DRAW "_ZN25QGraphicsDropShadowEffect4drawEP8QPainter"
#define DRAW_SOURCE "_ZN15QGraphicsEffect10drawSourceEP8QPainter"
#define MAX_VTABLE_ENTRIES 64

static int debug_enabled(void)
{
    static int enabled = -1;

    if (enabled == -1)
        enabled = getenv("WEMEET_DROP_SHADOW_FIX_DEBUG") != NULL;

    return enabled;
}

#define DEBUG(...)                                                              \
    do {                                                                        \
        if (debug_enabled())                                                   \
            fprintf(stderr, "[wemeet-drop-shadow-fix] " __VA_ARGS__);          \
    } while (0)

#define ERROR(...)                                                              \
    fprintf(stderr, "[wemeet-drop-shadow-fix] " __VA_ARGS__)

static void *lookup_symbol(void *handle, const char *name)
{
    void *address = dlvsym(handle, name, QT_SYMBOL_VERSION);

    /* Some vendor builds omit ELF symbol versions. Keep that case usable. */
    return address != NULL ? address : dlsym(handle, name);
}

static int is_wemeet_qt_widgets(const Dl_info *info)
{
    const char *basename;
    size_t basename_length;
    size_t soname_length;

    if (info->dli_fname == NULL)
        return 0;

    basename = strrchr(info->dli_fname, '/');
    basename = basename == NULL ? info->dli_fname : basename + 1;
    basename_length = strlen(basename);
    soname_length = strlen(QT_WIDGETS_SONAME);

    if (!((strcmp(basename, QT_WIDGETS_SONAME) == 0) ||
          (basename_length > soname_length &&
           strncmp(basename, QT_WIDGETS_SONAME, soname_length) == 0 &&
           basename[soname_length] == '.'))) {
        return 0;
    }

    /* Do not accidentally modify a desktop environment's system Qt. */
    return strstr(info->dli_fname, "/wemeet/") != NULL;
}

static int describe_symbol(void *address, Dl_info *info)
{
    memset(info, 0, sizeof(*info));
    return address != NULL && dladdr(address, info) != 0 &&
           info->dli_fbase != NULL;
}

static int change_page_protection(void *address, size_t length, int protection)
{
    long page_size = sysconf(_SC_PAGESIZE);
    uintptr_t page_start;
    uintptr_t page_end;

    if (page_size <= 0 || length == 0) {
        errno = EINVAL;
        return -1;
    }

    page_start = (uintptr_t)address & ~((uintptr_t)page_size - 1);
    page_end = ((uintptr_t)address + length + (uintptr_t)page_size - 1) &
               ~((uintptr_t)page_size - 1);

    return mprotect((void *)page_start, (size_t)(page_end - page_start),
                    protection);
}

static int install_drop_shadow_fix(void *qt_widgets)
{
    void **vtable;
    void *drop_shadow_draw;
    void *draw_source;
    Dl_info vtable_info;
    Dl_info draw_info;
    Dl_info draw_source_info;
    const ElfW(Sym) *vtable_symbol = NULL;
    size_t vtable_entries;
    size_t matching_slot = 0;
    size_t matches = 0;

    vtable = (void **)lookup_symbol(qt_widgets, DROP_SHADOW_VTABLE);
    drop_shadow_draw = lookup_symbol(qt_widgets, DROP_SHADOW_DRAW);
    draw_source = lookup_symbol(qt_widgets, DRAW_SOURCE);

    if (!describe_symbol(vtable, &vtable_info) ||
        !describe_symbol(drop_shadow_draw, &draw_info) ||
        !describe_symbol(draw_source, &draw_source_info)) {
        ERROR("required Qt symbols are unavailable\n");
        return -1;
    }

    if (vtable_info.dli_fbase != draw_info.dli_fbase ||
        vtable_info.dli_fbase != draw_source_info.dli_fbase ||
        !is_wemeet_qt_widgets(&vtable_info)) {
        ERROR("refusing symbols that do not belong to WeMeet's bundled Qt\n");
        return -1;
    }

    if (dladdr1(vtable, &vtable_info, (void **)&vtable_symbol,
                RTLD_DL_SYMENT) == 0 ||
        vtable_info.dli_saddr != vtable || vtable_symbol == NULL ||
        vtable_symbol->st_size < sizeof(void *) ||
        vtable_symbol->st_size % sizeof(void *) != 0 ||
        vtable_symbol->st_size > MAX_VTABLE_ENTRIES * sizeof(void *)) {
        ERROR("cannot determine a safe drop-shadow vtable extent\n");
        return -1;
    }

    vtable_entries = vtable_symbol->st_size / sizeof(void *);
    for (size_t i = 0; i < vtable_entries; ++i) {
        if (vtable[i] == drop_shadow_draw) {
            matching_slot = i;
            ++matches;
        }
    }

    if (matches != 1) {
        ERROR("expected one draw entry in a %zu-slot vtable, found %zu\n",
              vtable_entries, matches);
        return -1;
    }

    if (change_page_protection(&vtable[matching_slot], sizeof(void *),
                               PROT_READ | PROT_WRITE) != 0) {
        ERROR("cannot make vtable slot writable: %s\n", strerror(errno));
        return -1;
    }

    __atomic_store_n(&vtable[matching_slot], draw_source, __ATOMIC_RELEASE);

    /* Qt vtables reside in .data.rel.ro after relocation. */
    if (change_page_protection(&vtable[matching_slot], sizeof(void *),
                               PROT_READ) != 0) {
        ERROR("cannot restore vtable page protection: %s\n", strerror(errno));
        return -1;
    }

    DEBUG("replaced draw at vtable slot %zu in %s\n", matching_slot,
          vtable_info.dli_fname);
    return 0;
}

__attribute__((constructor)) static void initialize(void)
{
    /* libwemeet directly depends on Qt, so it is mapped before constructors. */
    void *qt_widgets =
        dlopen(QT_WIDGETS_SONAME, RTLD_LAZY | RTLD_NOLOAD | RTLD_LOCAL);

    if (qt_widgets == NULL) {
        DEBUG("%s is not loaded; leaving this process unchanged\n",
              QT_WIDGETS_SONAME);
        return;
    }

    install_drop_shadow_fix(qt_widgets);
    dlclose(qt_widgets);
}
