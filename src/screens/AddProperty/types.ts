export type FormState = {
  title: string;
  description: string;
  address: string;
  price: string; // stored as string to allow empty or formatted input
  priceFrequency: "monthly" | "annual";
  rooms: number | "";
  bathrooms: number;
  balconies: number;
  listingType: string;
  propertyType: string;
  amenities: string[];
  tags: string[];
};

export const initialForm: FormState = {
  title: "",
  description: "",
  address: "",
  price: "",
  priceFrequency: "monthly",
  rooms: "",
  bathrooms: 0,
  balconies: 0,
  listingType: "Colega de quarto",
  propertyType: "Apartamento",
  amenities: [],
  tags: [],
};
