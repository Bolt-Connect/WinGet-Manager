// Haalt de laatste release op van GitHub en werkt de UI bij:
//  - alle .version elementen krijgen het tag-nummer
//  - alle .release-status elementen krijgen "Public Beta" / "Stable" (NL: "Publieke Beta" / "Stabiel")
//  - de .hero-badge krijgt class .is-stable bij een stable release
// Bij fout (rate limit, geen netwerk) blijven de hardcoded fallback-waardes staan.
(function () {
  var lang = (document.documentElement.lang || 'en').toLowerCase();
  var labels = {
    en: { beta: 'Public Beta', stable: 'Stable' },
    nl: { beta: 'Publieke Beta', stable: 'Stabiel' }
  };
  var L = labels[lang] || labels.en;

  fetch('https://api.github.com/repos/Bolt-Connect/WinGetManager/releases/latest')
    .then(function (r) { return r.ok ? r.json() : null; })
    .then(function (d) {
      if (!d || !d.tag_name) return;

      var tag = 'v' + d.tag_name.replace(/^v/, '');
      document.querySelectorAll('.version').forEach(function (el) {
        el.textContent = tag;
      });

      var statusText = d.prerelease ? L.beta : L.stable;
      document.querySelectorAll('.release-status').forEach(function (el) {
        el.textContent = statusText;
      });

      if (!d.prerelease) {
        document.querySelectorAll('.hero-badge').forEach(function (el) {
          el.classList.add('is-stable');
        });
      }
    })
    .catch(function () { /* fallback blijft staan */ });
})();
