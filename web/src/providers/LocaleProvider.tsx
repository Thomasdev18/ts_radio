import { Context, createContext, useContext, useEffect, useState } from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { fetchNui } from "../utils/fetchNui";
import { debugData } from "../utils/debugData";

interface Locale {
  ui_playerMoney: string;
  ui_buttonText: string;
  ui_reset: string;
}

debugData(
  [
    {
      action: "setLocale",
      data: {
        ui_playerMoney: "Player Money",
        ui_buttonText: "Click to Get Player Money",
        ui_reset: "reset",
      },
    },
  ],
  2000,
);

interface LocaleContextValue {
  locale: Locale;
  setLocale: (locales: Locale) => void;
}

const LocaleCtx = createContext<LocaleContextValue | null>(null);

const LocaleProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [locale, setLocale] = useState<Locale>({
    ui_playerMoney: "",
    ui_buttonText: "",
    ui_reset: "",
  });

  useEffect(() => {
    fetchNui("loadLocale");
  }, []);

  useNuiEvent("setLocale", async (data: Locale) => setLocale(data));

  return (
    <LocaleCtx.Provider value={{ locale, setLocale }}>
      {children}
    </LocaleCtx.Provider>
  );
};

export default LocaleProvider;

export const useLocales = () =>
  useContext<LocaleContextValue>(LocaleCtx as Context<LocaleContextValue>);
