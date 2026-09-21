import QtQuick

QtObject {
  id: root

  property string activePanel: ""

  function isOpen(name): bool {
    return activePanel === name;
  }

  function open(name): void {
    activePanel = name || "";
  }

  function close(name): void {
    if (!name || activePanel === name) activePanel = "";
  }

  function toggle(name): void {
    activePanel = activePanel === name ? "" : name;
  }
}
