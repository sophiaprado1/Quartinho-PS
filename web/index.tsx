import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "./src/App.tsx";

// One-time reset of browser storage and caches to simulate first run
(function resetOnce() {
  const RESET_KEY = "firstRunResetPerformed";
  try {
    if (!localStorage.getItem(RESET_KEY)) {
      // Clear local/session storage
      localStorage.clear();
      sessionStorage.clear();
      // Clear Cache Storage (service workers / assets)
      if ("caches" in window) {
        caches.keys().then((keys) => keys.forEach((k) => caches.delete(k)));
      }
      // Try to clear IndexedDB databases (not supported everywhere)
      const anyIndexedDB = indexedDB as unknown as {
        databases?: () => Promise<Array<{ name?: string }>>;
        deleteDatabase: (name: string) => void;
      };
      if (anyIndexedDB.databases) {
        anyIndexedDB.databases!().then((dbs) => {
          dbs.forEach((db) => {
            if (db.name) anyIndexedDB.deleteDatabase(db.name);
          });
        });
      }
      // Mark reset done so it only runs once
      localStorage.setItem(RESET_KEY, "true");
    }
  } catch (_) {
    // ignore any errors
  }
})();

createRoot(document.getElementById("app") as HTMLElement).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
