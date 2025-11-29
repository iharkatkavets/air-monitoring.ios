# SPS30 Number Concentration and Health Impact

The **Sensirion SPS30** sensor measures airborne particles by *number concentration* (`#/cm³`) across several particle size ranges.  
This document describes what each PM category means, its typical sources, potential health effects, and guidance on safe number-concentration ranges.

---

### PM0.5 (0.3–0.5 µm)
**Typical sources:** Combustion residues, tobacco smoke, engine exhaust, and indoor aerosols.  
**Health impact:** These ultrafine particles can penetrate deep into the lungs and enter the bloodstream.  
They are associated with cardiovascular and respiratory diseases.

---

### PM1.0 (0.3–1.0 µm)
**Typical sources:** Diesel exhaust, cooking fumes, and industrial emissions.  
**Health impact:** Reaches the alveoli in the lungs and may cause inflammation.  
Long-term exposure contributes to chronic respiratory problems.

---

### PM2.5 (0.3–2.5 µm)
**Typical sources:** Vehicle emissions, wood burning, and atmospheric chemical reactions (secondary aerosols).  
**Health impact:** Aggravates asthma, bronchitis, and heart conditions.  
Long-term exposure increases the risk of premature death from cardiovascular and pulmonary diseases.

---

### PM4.0 (0.3–4.0 µm)
**Typical sources:** Industrial dust, construction sites, and resuspended soil particles.  
**Health impact:** Causes irritation of the throat and lungs and contributes to reduced lung function over time.

---

### PM10 (0.3–10 µm)
**Typical sources:** Road dust, pollen, mold spores, and coarse dust.  
**Health impact:** Affects the upper respiratory tract, causing coughing, eye irritation, and worsening of asthma.

---

## Typical Number Concentration Ranges

There are no official international safety limits for number concentration (`#/cm³`), but general reference values can help interpret SPS30 readings.

| Air quality condition | PM0.5–PM2.5 number concentration (particles/cm³) | Description |
|------------------------|--------------------------------------------------|--------------|
| **Very clean air** | < 500 | Fresh mountain or rural air |
| **Good indoor air** | 500 – 2 000 | Well-ventilated room |
| **Urban outdoor air** | 2 000 – 10 000 | Normal city street conditions |
| **Polluted indoor/outdoor** | 10 000 – 50 000 | Near traffic, cooking, or smoke |
| **Heavily polluted / smoky air** | > 100 000 | Close to vehicles, fire, or dust storm |

**Interpretation:**
- **< 2 000 #/cm³:** Excellent – clean environments, no significant health risk.  
- **2 000–10 000 #/cm³:** Acceptable – typical for residential or office air.  
- **> 10 000 #/cm³:** Caution – may cause respiratory irritation with prolonged exposure.  
- **> 100 000 #/cm³:** Dangerous – usually indicates severe pollution or smoke; short-term exposure may cause acute symptoms.

---

## WHO Mass Concentration Guidelines (for comparison)

| Parameter | Annual mean limit | 24-hour mean limit |
|------------|------------------|--------------------|
| **PM2.5** | 5 µg/m³ | 15 µg/m³ |
| **PM10** | 15 µg/m³ | 45 µg/m³ |

*(World Health Organization Air Quality Guidelines, 2021)*

---

### Summary
- The **SPS30** reports both **number** and **mass** concentrations of particles.  
- **Number concentration** is useful for detecting short-term changes or identifying pollution sources.  
- **Mass concentration (µg/m³)** should be used for official air-quality assessment.  
- Smaller particles (PM0.5–PM2.5) are most harmful because they can enter the bloodstream, while larger ones mainly irritate the upper airways.
