type PlanAnalysis = {
  isProfessional: boolean;
  isStarter: boolean;
  hasShowroom: boolean;
  isOldPlan: boolean;
  isExclusive: boolean;
  isOldProfessional: boolean;
};

export const isBeforeJanuary2025 = new Date() < new Date("2025-01-01");

export const isBefore14January2025 = new Date() < new Date("2025-01-14");

export const isBefore31January2025 = new Date() < new Date("2025-01-31");

export const analyzePlan = (planName?: string): PlanAnalysis => {
  let isProfessional = false;
  let isStarter = false;
  let hasShowroom = false;
  let isOldPlan = false;
  let isExclusive = false;
  let isOldProfessional = false;

  if (planName?.includes("Professional")) {
    isProfessional = true;
  } else if (planName?.includes("Starter")) {
    isStarter = true;
  }

  if (planName?.includes("Showroom")) {
    hasShowroom = true;
  }

  if (planName?.includes("Plan") || (planName && planName[0] === planName[0].toLowerCase())) {
    isOldPlan = true;
  }

  if (planName?.includes("(Exclusive)")) {
    isExclusive = true;
  }

  if (planName?.includes("professional")) {
    isOldProfessional = true;
  }

  return { isProfessional, isStarter, hasShowroom, isOldPlan, isExclusive, isOldProfessional };
};
