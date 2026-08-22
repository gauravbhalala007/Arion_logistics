// firebase/functions/src/vehicleChecks/index.ts
//
// Geführte Foto-Fahrzeuginspektion — Server-Teil.
//
//   onVehicleCheckCreated  Stufe 1: spiegelt jeden Check als Event nach
//                          users/{dspUid}/fleet_events (Fleet Hub).
//   analyzeVehicleCheck    Stufe 2: Vertex-AI-Bildanalyse, wird aus dem
//                          Trigger heraus aufgerufen (eine Kette, genau
//                          ein Modell-Call je Check).

export {onVehicleCheckCreated} from "./onCheckCreated";
export {analyzeVehicleCheck} from "./analyzeCheck";
