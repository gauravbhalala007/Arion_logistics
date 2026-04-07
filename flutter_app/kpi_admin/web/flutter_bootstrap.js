{{flutter_js}}
{{flutter_build_config}}

const searchParams = new URLSearchParams(window.location.search);
const renderer = searchParams.get('renderer');
const cpuOnlyParam = searchParams.get('cpuOnly');
const hostname = window.location.hostname;
const isLocalDev =
  hostname === 'localhost' ||
  hostname === '127.0.0.1' ||
  hostname === '[::1]';

const config = {};

if (renderer === 'canvaskit' || renderer === 'skwasm') {
  config.renderer = renderer;
}

if (cpuOnlyParam === 'true' || cpuOnlyParam === '1') {
  config.canvasKitForceCpuOnly = true;
} else if (cpuOnlyParam === 'false' || cpuOnlyParam === '0') {
  config.canvasKitForceCpuOnly = false;
}

_flutter.loader.load({
  config,
});
