const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

function serviceFunctions(filename, names, context) {
    const source = fs.readFileSync(path.join(__dirname, '../modules/services', filename), 'utf8');
    vm.createContext(context);
    for (const name of names) {
        const start = source.indexOf(`    function ${name}(`);
        assert.notEqual(start, -1, `Missing ${name}`);
        let end = source.indexOf('{', start) + 1;
        let depth = 1;
        while (depth && end < source.length) {
            if (source[end] === '{') depth++;
            if (source[end] === '}') depth--;
            end++;
        }
        vm.runInContext(source.slice(start, end), context);
        context.root[name] = context[name];
    }
}

const notices = [1, 2].map(id => ({id, popup: true, timer: {destroy() {}}, closeTimer: {
    running: false, start() { this.running = true; }
}}));
const expired = [];
const notificationContext = {
    root: {list: notices, timeoutWithAnimation() {}, timeout(id) { expired.push(id); }},
    NotificationUrgency: {Critical: 2}
};
serviceFunctions('Notifications.qml', ['popupTimeout', 'finishTimeout', 'timeoutNotification'], notificationContext);
assert.equal(notificationContext.popupTimeout(-1, 1), 5000);
assert.equal(notificationContext.popupTimeout(0, 1), 0);
assert.equal(notificationContext.popupTimeout(1200, 1), 1200);
assert.equal(notificationContext.popupTimeout(1200, 2), 1200);
assert.equal(notificationContext.popupTimeout(-1, 2), 0);
notificationContext.timeoutNotification(1);
notificationContext.timeoutNotification(2);
assert.ok(notices.every(notice => notice.closeTimer.running));
notificationContext.finishTimeout(1);
notificationContext.finishTimeout(2);
assert.ok(notices.every(notice => !notice.popup && notice.timer === null));
assert.deepEqual(expired, [1, 2]);

const clipboardContext = {root: {}};
serviceFunctions('ClipboardService.qml', ['enqueue', 'startNext'], clipboardContext);
const process = {pending: [], running: false};
clipboardContext.enqueue(process, {itemId: 'first', command: ['first']});
clipboardContext.enqueue(process, {itemId: 'second', command: ['second']});
assert.equal(process.itemId, 'first');
assert.equal(process.pending.length, 1);
process.running = false;
clipboardContext.startNext(process);
assert.equal(process.itemId, 'second');
assert.equal(process.pending.length, 0);

const recorderContext = {
    root: {videosDir: '/tmp/space and "quote"', starting: false},
    isRecording: false, starting: false,
    startProcess: {}, prepareProcess: {}, Date
};
serviceFunctions('ScreenRecorder.qml', ['startRecording'], recorderContext);
recorderContext.startRecording(true, true, 'region', '100x100+0+0; literal');
const command = recorderContext.startProcess.command;
assert.equal(command[0], 'gpu-screen-recorder');
assert.ok(command.includes('100x100+0+0; literal'));
assert.ok(command.includes('default_output|default_input'));
assert.ok(command.at(-1).startsWith('/tmp/space and "quote"/'));
assert.ok(recorderContext.prepareProcess.running);
console.log('Notification timing, clipboard request queue and recording argument tests passed');

const firstScreen = {}, removedScreen = {}, newScreen = {};
let destroyed = 0, created = 0;
const firstMonitor = {screen: firstScreen, destroy() { destroyed++; }};
const removedMonitor = {screen: removedScreen, destroy() { destroyed++; }};
const brightnessContext = {
    root: {monitors: [firstMonitor, removedMonitor]},
    Quickshell: {screens: [firstScreen, newScreen]},
    monitorComp: {createObject(parent, properties) { created++; return properties; }}
};
serviceFunctions('Brightness.qml', ['syncMonitors'], brightnessContext);
brightnessContext.syncMonitors();
assert.equal(brightnessContext.root.monitors[0], firstMonitor);
assert.equal(created, 1);
assert.equal(destroyed, 1);
brightnessContext.syncMonitors();
assert.equal(created, 1);
assert.equal(destroyed, 1);

const ddcContext = {
    root: {}, ready: true, isDdc: true, busNum: '7', writePending: false,
    monitor: {brightness: 0.2, rawMaxBrightness: 100}, setProc: {running: false}
};
serviceFunctions('Brightness.qml', ['syncBrightness'], ddcContext);
ddcContext.syncBrightness();
assert.equal(ddcContext.setProc.command.at(-1), 20);
ddcContext.monitor.brightness = 0.8;
ddcContext.syncBrightness();
assert.equal(ddcContext.setProc.command.at(-1), 20);
assert.equal(ddcContext.writePending, true);
ddcContext.setProc.running = false;
ddcContext.syncBrightness();
assert.equal(ddcContext.setProc.command.at(-1), 80);
console.log('Brightness hotplug ownership and DDC write serialization tests passed');

let weatherErrors = 0, weatherResponses = 0, weatherRefreshes = 0;
const weatherContext = {
    root: {
        wasCancelled: false, pendingRefresh: false, isLoading: true,
        handleError() { weatherErrors++; },
        handleResponse() { weatherResponses++; },
        updateWeather() { weatherRefreshes++; }
    },
    SuspendManager: {isSuspending: false},
    Qt: {callLater(callback) { callback(); }}
};
serviceFunctions('WeatherService.qml', ['finishRequest'], weatherContext);
weatherContext.finishRequest(124, '');
assert.equal(weatherErrors, 1);
assert.equal(weatherResponses, 0);
weatherContext.root.pendingRefresh = true;
weatherContext.finishRequest(0, 'stale location');
assert.equal(weatherResponses, 0);
assert.equal(weatherRefreshes, 1);
weatherContext.finishRequest(0, 'current location');
assert.equal(weatherResponses, 1);
weatherContext.root.wasCancelled = true;
weatherContext.finishRequest(143, '');
assert.equal(weatherErrors, 1);
assert.equal(weatherContext.root.isLoading, false);
console.log('Weather timeout, superseded request and cancellation tests passed');

const idleCommands = [];
const idleContext = {
    root: {
        generation: 4, triggered: {},
        activeListeners: [{timeout: 300, onTimeout: 'lock', onResume: 'restore'}],
        executeCommand(command) { idleCommands.push(command); }
    },
    CaffeineService: {inhibit: false}, SuspendManager: {isSuspending: false}
};
serviceFunctions('IdleService.qml', ['renderConfig', 'handleTimeout', 'handleResume', 'resumeAll'], idleContext);
const idleConfig = idleContext.renderConfig([{timeout: 300, onTimeout: 'echo # {\nunsafe config'}], 4);
assert.ok(idleConfig.includes('timeout = 300'));
assert.ok(idleConfig.includes('pangu idle timeout 4 0'));
assert.ok(!idleConfig.includes('unsafe config'));
idleContext.handleTimeout(3, 0);
assert.equal(idleCommands.length, 0);
idleContext.handleTimeout(4, 0);
idleContext.handleTimeout(4, 0);
assert.deepEqual(idleCommands, ['lock']);
idleContext.handleResume(3, 0);
assert.deepEqual(idleCommands, ['lock']);
idleContext.resumeAll();
idleContext.handleResume(4, 0);
assert.deepEqual(idleCommands, ['lock', 'restore']);
idleContext.CaffeineService.inhibit = true;
idleContext.handleTimeout(4, 0);
assert.equal(idleCommands.length, 2);
console.log('Idle daemon generation, command isolation and resume tests passed');

const wallpaperContext = {
    root: {},
    wallpaperConfig: {adapter: {perScreenWallpapers: {'DP-2': 'old'}, currentWall: 'first'}},
    wallpaperPaths: ['first', 'second'], currentIndex: 0, initialLoadCompleted: true,
    Quickshell: {screens: [{name: 'DP-1'}, {name: 'DP-2'}]},
    runMatugenForCurrentWallpaper() {}, generateLockscreenFrame() {}, console
};
serviceFunctions('../widgets/dashboard/wallpapers/WallpaperService.qml', ['setWallpaper', 'clearPerScreenWallpaper'], wallpaperContext);
wallpaperContext.setWallpaper('second', 'DP-2');
assert.equal(wallpaperContext.wallpaperConfig.adapter.currentWall, 'first');
assert.equal(wallpaperContext.wallpaperConfig.adapter.perScreenWallpapers['DP-2'], 'second');
wallpaperContext.setWallpaper('second', 'DP-1');
assert.equal(wallpaperContext.wallpaperConfig.adapter.currentWall, 'second');
wallpaperContext.clearPerScreenWallpaper('DP-1');
assert.equal(wallpaperContext.wallpaperConfig.adapter.perScreenWallpapers['DP-1'], undefined);
assert.equal(wallpaperContext.wallpaperConfig.adapter.perScreenWallpapers['DP-2'], 'second');
console.log('Shared wallpaper per-monitor selection tests passed');

const settingsContext = {root: {editGroups: {}, pauseAutoSave: false}};
serviceFunctions('../../config/Config.qml', ['beginEdit', 'endEdit', 'isPaused'], settingsContext);
settingsContext.beginEdit('theme', ['theme']);
settingsContext.beginEdit('shell', ['bar', 'system']);
assert.equal(settingsContext.isPaused('theme'), true);
assert.equal(settingsContext.isPaused('weather'), false);
settingsContext.endEdit('theme');
assert.equal(settingsContext.isPaused('theme'), false);
assert.equal(settingsContext.isPaused('system'), true);
settingsContext.beginEdit('second', ['system']);
settingsContext.endEdit('shell');
assert.equal(settingsContext.isPaused('system'), true);
settingsContext.root.pauseAutoSave = true;
settingsContext.endEdit('second');
assert.equal(settingsContext.isPaused('weather'), true);
settingsContext.root.pauseAutoSave = false;
assert.equal(settingsContext.isPaused('system'), false);
console.log('Independent settings drafts and batch-save inhibition tests passed');

const globalsSource = fs.readFileSync(path.join(__dirname, '../modules/globals/GlobalStates.qml'), 'utf8');
assert.match(globalsSource, /Config\.adapterKeys\(/, 'GlobalStates must derive tracked keys from the adapters');
const sectionNames = JSON.parse(globalsSource.match(/const names = (\[[^\]]*\]);/)[1]);
const shellPanelSource = fs.readFileSync(path.join(__dirname, '../modules/widgets/dashboard/controls/ShellPanel.qml'), 'utf8');
for (const match of shellPanelSource.matchAll(/Config\.(\w+)\.(\w+)\s*=(?!=)/g)) {
    assert.ok(sectionNames.includes(match[1]), `Shell section is not drafted: ${match[1]}.${match[2]}`);
}
console.log('Shell Apply/Discard coverage matches editable controls');

let fileReloads = 0;
const reloadContext = {
    root: {}, ready: true, reloading: false, reloadPending: false, name: 'theme',
    Config: {isPaused() { return true; }}, reload() { fileReloads++; }
};
serviceFunctions('../../config/ConfigFile.qml', ['reloadConfig'], reloadContext);
reloadContext.reloadConfig();
assert.equal(fileReloads, 0);
assert.equal(reloadContext.reloadPending, true);
reloadContext.Config.isPaused = () => false;
reloadContext.reloadConfig();
assert.equal(fileReloads, 1);
assert.equal(reloadContext.reloadPending, false);
assert.equal(reloadContext.reloading, true);
console.log('Settings file reload waits for pending edits');

const monitorA = {name: 'DP-1'}, monitorB = {name: 'DP-2'};
const clearedGrabs = [];
const grabContext = {
    root: {}, _grabs: {}, _grabOrder: [], Qt: {callLater(callback) { callback(); }}
};
serviceFunctions('FocusGrabManager.qml', ['requestGrab', 'releaseGrab', 'hasGrabFor', 'clearTopGrab'], grabContext);
grabContext.requestGrab('first', () => clearedGrabs.push('first'), [{screen: monitorA}]);
assert.equal(grabContext.hasGrabFor(monitorA), true);
assert.equal(grabContext.hasGrabFor(monitorB), false);
grabContext.requestGrab('second', () => clearedGrabs.push('second'), [{screen: monitorB}]);
grabContext.clearTopGrab(monitorA);
assert.deepEqual(clearedGrabs, ['first']);
assert.equal(grabContext.hasGrabFor(monitorB), true);
grabContext.releaseGrab('second');
assert.equal(grabContext.hasGrabFor(monitorB), false);
console.log('Focus grabs and dismissal stay on their owning monitor');

const visibilityContext = {
    root: {}, screens: {}, currentActiveModule: 'dashboard', lastFocusedScreen: 'DP-1',
    Compositor: {focusedMonitor: {name: 'DP-2'}},
    Quickshell: {screens: [monitorA, monitorB]}, clearAll() {},
    screenPropertiesComponent: {createObject(parent, properties) { return properties; }}
};
serviceFunctions('Visibilities.qml', ['_updateMap', 'getForScreen', 'syncScreens', 'isActiveOnFocusedScreen'], visibilityContext);
const oldScreens = visibilityContext.screens;
assert.equal(visibilityContext.getForScreen('DP-2'), null);
assert.equal(visibilityContext.screens, oldScreens);
visibilityContext.syncScreens();
const screenState = visibilityContext.getForScreen('DP-2');
assert.notEqual(visibilityContext.screens, oldScreens);
assert.equal(visibilityContext.getForScreen('DP-2'), screenState);
assert.equal(visibilityContext.isActiveOnFocusedScreen('dashboard'), false);
visibilityContext.Compositor.focusedMonitor = {name: 'DP-1'};
assert.equal(visibilityContext.isActiveOnFocusedScreen('dashboard'), true);
console.log('Monitor state registration is reactive and shortcuts target focused screens');

const paletteContext = {root: {}, pendingPalette: [], paletteProcess: {running: false}};
serviceFunctions('../widgets/dashboard/wallpapers/WallpaperService.qml', ['requestPalette', 'startPalette'], paletteContext);
paletteContext.requestPalette(['matugen', 'first']);
paletteContext.requestPalette(['matugen', 'obsolete']);
paletteContext.requestPalette(['preset', 'latest']);
assert.equal(paletteContext.paletteProcess.command[1], 'first');
paletteContext.paletteProcess.running = false;
paletteContext.startPalette();
assert.equal(paletteContext.paletteProcess.command[1], 'latest');
assert.equal(paletteContext.pendingPalette.length, 0);
console.log('Palette writes are serialized and superseded requests are coalesced');

const presetDirectory = fs.mkdtempSync(path.join(require('node:os').tmpdir(), 'pangu-palette-'));
try {
    const presetName = "Quote's preset";
    const userDir = path.join(presetDirectory, 'user', presetName);
    fs.mkdirSync(userDir, {recursive: true});
    fs.writeFileSync(path.join(userDir, 'dark.json'), '{"background":"#123456"}');
    let presetCommand;
    const presetContext = {
        root: {}, activeColorPreset: presetName, Config: {theme: {lightMode: false}},
        officialColorPresetsDir: path.join(presetDirectory, 'official'),
        colorPresetsDir: path.join(presetDirectory, 'user'),
        Paths: {cachePath(name) { return path.join(presetDirectory, name); }},
        requestPalette(command) { presetCommand = command; }
    };
    serviceFunctions('../widgets/dashboard/wallpapers/WallpaperService.qml', ['applyColorPreset'], presetContext);
    presetContext.applyColorPreset();
    const result = require('node:child_process').spawnSync(presetCommand[0], presetCommand.slice(1));
    assert.equal(result.status, 0, result.stderr.toString());
    assert.equal(fs.readFileSync(path.join(presetDirectory, 'colors.json'), 'utf8'), '{"background":"#123456"}');
} finally {
    fs.rmSync(presetDirectory, {recursive: true});
}
console.log('Preset copying preserves quoted paths and falls back to user presets');

const shaderWrites = [], shaderUpdates = [];
const shaderContext = {
    root: {}, Qt: {callLater(callback) { callback(); }}, shaderWriting: false, pendingShader: 'first', shaderSlot: 0,
    currentScreenName: 'DP-1', mpvShaderPath: '', usesMpv: true, tintEnabled: true,
    Paths: {runtimePath(name) { return '/runtime/' + name; }},
    mpvShaderWriter: {path: '', setText(text) { shaderWrites.push(text); }},
    updateMpvRuntime(enabled) { shaderUpdates.push(enabled); }
};
shaderContext.wallpaper = shaderContext;
serviceFunctions('../widgets/dashboard/wallpapers/Wallpaper.qml', ['startShaderWrite', 'finishShaderWrite'], shaderContext);
shaderContext.startShaderWrite();
const firstShaderPath = shaderContext.mpvShaderWriter.path;
assert.equal(shaderContext.mpvShaderPath, '');
shaderContext.pendingShader = 'latest';
shaderContext.startShaderWrite();
assert.deepEqual(shaderWrites, ['first']);
shaderContext.finishShaderWrite(true);
assert.deepEqual(shaderWrites, ['first', 'latest']);
assert.deepEqual(shaderUpdates, []);
assert.notEqual(shaderContext.mpvShaderWriter.path, firstShaderPath);
shaderContext.tintEnabled = false;
shaderContext.finishShaderWrite(true);
assert.deepEqual(shaderUpdates, [false]);
shaderContext.pendingShader = 'failed';
shaderContext.startShaderWrite();
const committedShaderPath = shaderContext.mpvShaderPath;
shaderContext.finishShaderWrite(false);
assert.equal(shaderContext.mpvShaderPath, committedShaderPath);
assert.equal(shaderContext.shaderWriting, false);
console.log('Shader writes publish only completed files and respect the latest tint setting');

const ipcContext = {
    root: {}, queue: [], job: null,
    ipcRetryTimer: {job: null, stop() {}}, pump() {}
};
serviceFunctions('../widgets/dashboard/wallpapers/Wallpaper.qml', ['send'], ipcContext);
ipcContext.send('/mpv.sock', ['set_property', 'glsl-shaders', 'old'], 10);
ipcContext.job = ipcContext.queue.shift();
ipcContext.ipcRetryTimer.job = {...ipcContext.job};
ipcContext.send('/mpv.sock', ['set_property', 'glsl-shaders', 'new'], 10);
ipcContext.send('/mpv.sock', ['set_property', 'glsl-shaders', ''], 10);
assert.equal(ipcContext.job.retries, 0);
assert.equal(ipcContext.ipcRetryTimer.job, null);
assert.equal(ipcContext.queue.length, 1);
assert.equal(JSON.parse(ipcContext.queue[0].data).command[2], '');
console.log('New MPV settings supersede queued commands and stale retries');

const engineDirectory = fs.mkdtempSync(path.join(require('node:os').tmpdir(), 'pangu-engine-'));
try {
    const {spawnSync} = require('node:child_process');
    const configDir = path.join(engineDirectory, 'Linux Wallpaper Engine');
    fs.mkdirSync(configDir);
    const background = "/wallpapers/Quote's scene";
    fs.writeFileSync(path.join(configDir, 'settings.json'), JSON.stringify({
        audioProcessing: true, pauseOnFullscreen: false, volume: 80, disableMouse: true
    }));
    fs.writeFileSync(path.join(configDir, 'wallpaper-overrides.json'), JSON.stringify({overrides: {
        [background]: {audioProcessing: false, disableMouse: false, volume: 0,
            customProperties: {caption: 'literal $value; with spaces'}}
    }}));
    const bash = spawnSync('bash', ['-c', 'command -v bash'], {encoding: 'utf8'}).stdout.trim();
    fs.writeFileSync(path.join(engineDirectory, 'linux-wallpaperengine'),
        `#!${bash}\nprintf '%s\\n' "$$" "$@"\n`, {mode: 0o755});
    const result = spawnSync('bash', [path.join(__dirname, '../scripts/wallpaperengine.sh'),
        'apply', background, 'DP-1'], {encoding: 'utf8', env: {
            ...require('node:process').env, XDG_CONFIG_HOME: engineDirectory,
            PATH: engineDirectory + ':' + require('node:process').env.PATH
        }});
    assert.equal(result.status, 0, result.stderr);
    const args = result.stdout.trim().split('\n');
    assert.equal(Number(args.shift()), result.pid, 'Renderer must replace the owned process');
    assert.equal(args[args.indexOf('--bg') + 1], background);
    assert.equal(args[args.indexOf('--volume') + 1], '0');
    assert.ok(args.includes('--no-audio-processing'));
    assert.ok(args.includes('--no-fullscreen-pause'));
    assert.ok(!args.includes('--disable-mouse'));
    assert.equal(args[args.indexOf('--set-property') + 1], 'caption=literal $value; with spaces');
} finally {
    fs.rmSync(engineDirectory, {recursive: true});
}
console.log('Wallpaper Engine keeps process ownership, false overrides, and literal arguments');

const exportWrites = [], exportNotifications = [];
const exportContext = {
    root: {}, pendingText: null, savedText: null, writingText: '', saving: false,
    directoryReady: true, Qt: {callLater(callback) { callback(); }},
    setText(text) { exportWrites.push(text); }, written() { exportNotifications.push(exportContext.savedText); }
};
serviceFunctions('../theme/ThemeFile.qml', ['write', 'startWrite', 'finishWrite'], exportContext);
exportContext.write('first');
exportContext.write('discarded');
exportContext.write('latest');
exportContext.finishWrite(true);
assert.deepEqual(exportNotifications, []);
assert.deepEqual(exportWrites, ['first', 'latest']);
exportContext.finishWrite(true);
assert.deepEqual(exportNotifications, ['latest']);
exportContext.write('latest');
assert.equal(exportWrites.length, 2);
exportContext.write('retry');
exportContext.finishWrite(false);
exportContext.write('retry');
assert.equal(exportWrites.length, 4);
console.log('Theme exports coalesce edits, skip unchanged content, and retry failed writes');

const nightTimer = {interval: 0, running: false, stop() { this.running = false; }, restart() { this.running = true; }};
const nightContext = {
    root: {}, active: true, restored: true, stopping: false, restartFailures: 0,
    restartTimer: nightTimer, wlsunsetProcess: {running: true},
    Config: {initialLoadComplete: true}, console: {warn() {}}
};
serviceFunctions('NightLightService.qml', ['reconcile', 'processExited'], nightContext);
nightContext.reconcile();
assert.equal(nightContext.active, true);
assert.equal(nightContext.stopping, true);
assert.equal(nightContext.wlsunsetProcess.running, false);
nightContext.active = false;
nightContext.reconcile();
nightContext.processExited(0);
assert.equal(nightTimer.running, false);
nightContext.active = true;
for (let i = 0; i < 12; i++) nightContext.processExited(1);
assert.equal(nightTimer.interval, 30000);
assert.equal(nightContext.active, true);
console.log('Night-light restarts preserve intent, respect disabling, and back off after failures');

const autoContext = {
    root: {enabled: true}, SuspendManager: {isSuspending: false},
    schedule: {day: 480, night: 1200}, boundaryTimer: {restart() {}},
    Config: {initialLoadComplete: true, theme: {lightMode: null}, isPaused() { return true; }, save() { throw new Error('Draft was saved'); }}
};
serviceFunctions('AutoThemeService.qml', ['minutesOf', 'isLightAt', 'nextBoundary', 'apply'], autoContext);
assert.equal(autoContext.minutesOf('23:59', 480), 1439);
for (const time of ['24:00', '08:99', '8:30garbage', '', undefined])
    assert.equal(autoContext.minutesOf(time, 480), 480);
assert.equal(autoContext.isLightAt(600, 480, 1200), true);
assert.equal(autoContext.isLightAt(60, 1200, 480), true);
assert.equal(autoContext.isLightAt(600, 1200, 480), false);
assert.equal(autoContext.isLightAt(480, 480, 480), false);
const late = new Date(2026, 8, 6, 23, 0);
assert.equal(autoContext.nextBoundary(late, 1200, 480), new Date(2026, 8, 7, 8, 0).getTime());
autoContext.apply();
assert.equal(autoContext.Config.theme.lightMode, null);
assert.ok(autoContext.boundaryTimer.interval > 0);
console.log('Automatic theme validates times, handles midnight, and leaves settings drafts alone');

let usageSignals = 0;
const usageContext = {
    root: {}, usageData: {}, pendingUsage: [], dataLoaded: false,
    store: {ready: true, data: {}, save() {}},
    saveTimer: {restart() {}}, Date, maxBoostScore: 200, dayInMs: 86400000,
    usageDataReady() {}, usageChanged() { usageSignals++; }
};
serviceFunctions('UsageTracker.qml', ['validate', 'finishLoad', 'recordUsage', 'getUsageScore'], usageContext);
usageContext.recordUsage('early.desktop');
const loadedUsage = usageContext.validate({
    'early.desktop': {count: 4, lastUsed: Date.now()},
    invalid: {count: 'oops', lastUsed: null},
    future: {count: 1, lastUsed: Date.now() + 1e12}
});
usageContext.usageData = loadedUsage;
usageContext.store.data = loadedUsage;
usageContext.finishLoad();
assert.equal(usageContext.usageData['early.desktop'].count, 5);
assert.equal(usageContext.getUsageScore('invalid'), 0);
assert.ok(usageContext.getUsageScore('future') <= 200 + Math.log(2) * 20);
usageContext.recordUsage('__proto__');
assert.equal(usageContext.usageData.__proto__.count, 1);
assert.ok(Number.isFinite(usageContext.getUsageScore('__proto__')));
assert.equal(usageSignals, 2);
const settled = usageContext.usageData;
usageContext.finishLoad();
assert.equal(usageContext.usageData, settled);
console.log('Usage history validates persisted data and preserves launches during initial loading');

const launchRequests = [];
const launchContext = {
    root: {}, ApplicationLauncher: {launchDesktop(id) { launchRequests.push(id); }}
};
serviceFunctions('AppSearch.qml', ['launchApp'], launchContext);
launchContext.launchApp({id: 'terminal-app.desktop', runInTerminal: true, command: ['wrong fallback']});
assert.deepEqual(launchRequests, ['terminal-app.desktop']);
launchContext.launchApp(null);
assert.equal(launchRequests.length, 1);
const scopeContext = {root: {}};
serviceFunctions('ApplicationLauncher.qml', ['scopedCommand'], scopeContext);
const scoped = scopeContext.scopedCommand(['xdg-open', '/path/with $literal and spaces']);
assert.ok(scoped.includes('--expand-environment=no'));
assert.ok(scoped.includes('--slice=app.slice'));
assert.equal(scoped[scoped.length - 1], '/path/with $literal and spaces');
console.log('Application launches use desktop IDs and isolated scopes with literal arguments');

const placementCalls = [];
const oldToplevel = {};
const staleClients = [{title: "Pangu Settings", nativeToplevel: oldToplevel, address: "old", workspace: {id: 1}}];
const placementContext = {
    root: {},
    clientsBeforeMapping: [oldToplevel],
    settingsWindow: {title: "Pangu Settings"},
    settingsTab: {focusSearchInput() {}},
    GlobalStates: {settingsTargetWorkspaceId: 2},
    Compositor: {clients: {values: staleClients}, dispatch(command) { placementCalls.push(command); }}
};
serviceFunctions('../widgets/config/SettingsWindow.qml', ['placeOnTargetWorkspace'], placementContext);
assert.equal(placementContext.placeOnTargetWorkspace(), false);
assert.equal(placementCalls.length, 0);
placementContext.Compositor.clients.values = staleClients.map(client => ({...client}));
assert.equal(placementContext.placeOnTargetWorkspace(), false);
placementContext.Compositor.clients.values = [{title: "Pangu Settings", nativeToplevel: {}, address: "new", workspace: {id: 1}}];
assert.equal(placementContext.placeOnTargetWorkspace(), true);
assert.deepEqual(placementCalls, ['movetoworkspacesilent 2, address:new', 'focuswindow address:new']);

const themeWrites = [];
const themeContext = {
    root: {},
    Qt: {callLater(callback) {}},
    directoryReady: true,
    saving: false,
    pendingText: "",
    savedText: null,
    writingText: "",
    prepareDirectory: {running: false},
    setText(text) { themeWrites.push(text); },
    written() { themeContext.writeCount = (themeContext.writeCount || 0) + 1; }
};
serviceFunctions('../theme/ThemeFile.qml', ['startWrite'], themeContext);
themeContext.startWrite();
assert.deepEqual(themeWrites, []);
assert.equal(themeContext.savedText, "");
assert.equal(themeContext.writeCount, 1);
themeContext.pendingText = "content";
themeContext.startWrite();
assert.deepEqual(themeWrites, ["content"]);
assert.equal(themeContext.saving, true);
console.log('Theme exports treat an empty write as a completed no-op');

const composerContext = {root: {gaps: {}}};
serviceFunctions('Compositor.qml', ['handleRawEvent', 'gapFor'], composerContext);
composerContext.handleRawEvent({name: 'custom', data: 'centergap,DP-1,100,500,1'});
let gap = composerContext.gapFor('DP-1');
assert.equal(gap.x, 100);
assert.equal(gap.width, 500);
assert.equal(gap.square, true);
composerContext.handleRawEvent({name: 'custom', data: 'centergap,DP-1,100,500,1'});
assert.equal(composerContext.gapFor('DP-1').width, 500);
composerContext.handleRawEvent({name: 'custom', data: 'centergap,DP-1,0,0,0'});
assert.equal(composerContext.gapFor('DP-1'), null);
composerContext.handleRawEvent({name: 'custom', data: 'centergap,DP-2,0,0,0'});
composerContext.handleRawEvent({name: 'workspace', data: 'ignored'});
assert.equal(Object.keys(composerContext.root.gaps).length, 0);
console.log('Centered-layout gap events are parsed and cleared per screen');

const detailState = {
    selectedIndex: 2, renameHighlightsCancel: false,
    deleteMode: false, pendingDeleteId: '', originalSelectedIndex: -1, deleteButtonIndex: 0,
    renameMode: false, pendingRenameId: '', pendingRenameName: '', renameSelectedIndex: -1, renameButtonIndex: 1, pendingRenamedId: '',
    refreshes: 0, focuses: 0, resultsIndex: -1,
    refresh() { this.refreshes++; }, focusSearch() { this.focuses++; },
    setResultsCurrentIndex(value) { this.resultsIndex = value; },
    prepareRename(id) { return 'name:' + id; }
};
const detailContext = {root: detailState, ctrl: detailState};
serviceFunctions('../components/ListDetailController.qml', ['enterDeleteMode', 'cancelDeleteMode', 'enterRenameMode', 'cancelRenameMode', 'cancelModes'], detailContext);
detailContext.enterDeleteMode('a');
assert.equal(detailState.deleteMode, true);
assert.equal(detailState.pendingDeleteId, 'a');
assert.equal(detailState.originalSelectedIndex, 2);
detailState.selectedIndex = 4;
detailContext.cancelDeleteMode();
assert.equal(detailState.deleteMode, false);
assert.equal(detailState.selectedIndex, 2);
assert.equal(detailState.resultsIndex, 2);
assert.equal(detailState.refreshes, 1);
assert.equal(detailState.focuses, 1);
detailContext.enterRenameMode('b');
assert.equal(detailState.renameMode, true);
assert.equal(detailState.pendingRenameName, 'name:b');
assert.equal(detailState.renameSelectedIndex, 2);
detailState.pendingRenamedId = 'b';
detailState.selectedIndex = 9;
detailContext.cancelRenameMode();
assert.equal(detailState.renameMode, false);
assert.equal(detailState.pendingRenameName, '');
assert.equal(detailState.selectedIndex, 9, 'A pending rename must not restore the selection');
console.log('List-detail delete/rename state machine is shared');

const controlsDir = path.join(__dirname, '../modules/widgets/dashboard/controls');
const indexSource = fs.readFileSync(path.join(controlsDir, 'SettingsIndex.qml'), 'utf8');
const indexEntries = [...indexSource.matchAll(/\{ label: "([^"]*)", keywords: "[^"]*", section: "(\w*)", subSection: "(\w*)", subLabel: "([^"]*)"/g)]
    .map(match => ({label: match[1], section: match[2], subSection: match[3], subLabel: match[4]}));
assert.ok(indexEntries.length > 200, 'Expected the settings search index to be populated');
const settingsTab = fs.readFileSync(path.join(controlsDir, 'SettingsTab.qml'), 'utf8');
const panelBlock = settingsTab.match(/panelComponents: \[([\s\S]*?)\n\s*\]/)[1];
const panels = {};
for (const match of panelBlock.matchAll(/component: "(\w+\.qml)",\s*\n\s*section: "(\w+)"/g))
    panels[match[2]] = match[1];
const subsections = {};
for (const [section, file] of Object.entries(panels)) {
    const source = fs.readFileSync(path.join(controlsDir, file), 'utf8');
    subsections[section] = new Set([...source.matchAll(/currentSection === "(\w+)"/g)].map(match => match[1]));
}
for (const entry of indexEntries) {
    assert.ok(entry.label.length > 0, `Settings index entry has no label (${entry.section}/${entry.subSection})`);
    assert.ok(panels[entry.section], `Settings index targets an unknown section: ${entry.section}`);
    if (entry.subSection) {
        assert.ok(subsections[entry.section].has(entry.subSection),
            `Settings index targets an unknown subsection: ${entry.section} > ${entry.subSection}`);
        assert.ok(entry.subLabel.length > 0, `Settings index entry ${entry.section} > ${entry.subSection} has no subLabel`);
    }
}
for (const [section, subs] of Object.entries(subsections)) {
    for (const sub of subs) {
        assert.ok(indexEntries.some(entry => entry.section === section && entry.subSection === sub),
            `Panel subsection is not searchable: ${section} > ${sub}`);
    }
}
console.log('Settings search index targets match the panels');

const configSource = fs.readFileSync(path.join(__dirname, '../config/Config.qml'), 'utf8');
assert.match(configSource, /name: "pinnedapps"\n\s*path: Paths\.dataPath\("pinnedapps\.json"\)/,
    'pinnedapps must live in the shell data dir that nix overrides target');
console.log('Pinned apps path matches the nix override target');
