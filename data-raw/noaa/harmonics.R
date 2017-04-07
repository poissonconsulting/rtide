source("data-raw/noaa/header.R")

harmonics <- TideHarmonics::harmonics
rownames(harmonics) <- harmonics$name
harmonics <- harmonics[TideHarmonics::hc37,]
rownames(harmonics) <- NULL

harmonics$HarmonicName <- c(
    "M2", "S2", "N2", "K1", "M4", "O1", "M6", "MK3", "S4", "MN4", "NU2", "S6",
    "MU2", "2N2", "OO1", "LAM2", "S1", "M1", "J1", "MM", "SSA", "SA", "MSF",
    "MF", "RHO", "Q1", "T2", "R2", "2Q1", "P1", "2SM2", "M3", "L2", "2MK3",
    "K2", "M8", "MS4")

harmonics %<>% select(Harmonic = name, HarmonicName, Speed = speed)

harmonics %<>% as.tbl()

saveRDS(harmonics, "data-raw/noaa/data/harmonics.rds")
