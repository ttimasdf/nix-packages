'use strict';

const qtWidgetsModulePrefix = 'libQt5Widgets.so.5';
const dropShadowDrawSymbol = '_ZN25QGraphicsDropShadowEffect4drawEP8QPainter';
const drawSourceSymbol = '_ZN15QGraphicsEffect10drawSourceEP8QPainter';
const hookedModules = new Set();

const moduleObserver = Process.attachModuleObserver({
    onAdded(module) {
        if (
            module.name !== qtWidgetsModulePrefix &&
            !module.name.startsWith(`${qtWidgetsModulePrefix}.`)
        ) {
            return;
        }

        const moduleKey = module.base.toString();
        if (hookedModules.has(moduleKey)) {
            return;
        }

        const dropShadowDraw = module.findExportByName(dropShadowDrawSymbol);
        const drawSource = module.findExportByName(drawSourceSymbol);

        if (dropShadowDraw === null || drawSource === null) {
            console.error(
                `[wemeet-frida] Required Qt symbols are unavailable in ${module.path}: ` +
                `dropShadowDraw=${dropShadowDraw}, drawSource=${drawSource}`
            );
            return;
        }

        try {
            Interceptor.replaceFast(dropShadowDraw, drawSource);
            Interceptor.flush();
            hookedModules.add(moduleKey);
            console.log(
                `[wemeet-frida] Replaced QGraphicsDropShadowEffect::draw at ` +
                `${dropShadowDraw} with QGraphicsEffect::drawSource at ${drawSource}`
            );
        } catch (error) {
            console.error(`[wemeet-frida] Failed to install drop-shadow hook: ${error}`);
        }
    },

    onRemoved(module) {
        if (
            module.name === qtWidgetsModulePrefix ||
            module.name.startsWith(`${qtWidgetsModulePrefix}.`)
        ) {
            hookedModules.delete(module.base.toString());
        }
    }
});
