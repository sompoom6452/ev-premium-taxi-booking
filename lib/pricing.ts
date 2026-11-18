export type ServiceType = 'one_way'|'round_trip'|'hourly'|'daily'|'airport'|'interprovincial';
export type PricingInput = { serviceType: ServiceType; outboundKm?: number; returnKm?: number; hours?: number; days?: number; additionalFee?: number; discount?: number; ratePerKm: number; hourlyRate: number; dailyRate: number; minimumFare: number; };
export function calculateFare(x: PricingInput) {
  const n = (v:number|undefined) => Number.isFinite(v) && (v ?? 0) > 0 ? Number(v) : 0;
  let base = 0;
  if (x.serviceType === 'one_way' || x.serviceType === 'airport' || x.serviceType === 'interprovincial') base = n(x.outboundKm) * n(x.ratePerKm);
  if (x.serviceType === 'round_trip') base = (n(x.outboundKm) + n(x.returnKm)) * n(x.ratePerKm);
  if (x.serviceType === 'hourly') base = n(x.hours) * n(x.hourlyRate);
  if (x.serviceType === 'daily') base = n(x.days) * n(x.dailyRate);
  const subtotal = base + n(x.additionalFee);
  const total = Math.max(n(x.minimumFare), subtotal - n(x.discount));
  return { baseFare: Math.round(base*100)/100, additionalFee:n(x.additionalFee), discount:n(x.discount), total:Math.round(total*100)/100, deposit:500, balance:Math.max(0,Math.round((total-500)*100)/100) };
}
