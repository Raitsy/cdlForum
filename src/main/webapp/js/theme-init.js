/* Theme initialization – must be inlined in <head> BEFORE any rendering
   to prevent flash of wrong theme (FOUT). */
(function () {
    var theme = localStorage.getItem('cdl-theme') || 'light';
    document.documentElement.setAttribute('data-theme', theme);
}());
