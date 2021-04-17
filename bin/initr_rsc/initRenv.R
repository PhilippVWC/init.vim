# ======================================================
# R-Skript zum Initialisieren des Renv-Projektes
#------------------------------------------------------
# Voraussetzungen:
# 1.  Die .Rprofile-Datei ist im Wurzel-Verzeichnis
#     des Renv- bzw. Git-Projektes (gleiches Projekt)
#     zu hinterlegen.
# 2.  Die Variable "projectPath" muss den Pfad zum
#     Projektordner enthalten und in .Rprofile definiert
#     sein.
#------------------------------------------------------
# Philipp van Wickevoort Crommelin (pvwc)
# parcIT GmbH
# ======================================================
cat("### Rscript to initialize renv in current wd\n")
if (!exists("projectPath")) {
  stop("Variable \"projectPath\" unknown.")
}
# Check devtools dependency first
if (!("renv" %in% installed.packages()[, "Package"])) {
  tryCatch(
    expr = {
      cat(paste0(
        "### Install renv first ###\n",
        "### This is done only once ###\n"
      ))
      install.packages("renv")
      cat("### renv sucessfully installed ###\n")
    },
    warning = function(w) {
      stop("renv installation exited with warning")
    },
    error = function(e) {
      stop("renv could not be installed")
    }
  )
}
renv::init(
  project = projectPath,
  bare = FALSE,
  force = TRUE,
  restart = FALSE
)
cat("### Successfully initialized renv ###\n")
