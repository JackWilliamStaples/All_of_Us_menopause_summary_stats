#### sr-WGS person IDs (full AoURP cohort)
library(tidyverse)
library(bigrquery)

# This query represents dataset "VERSION8_Has_srWGS_all_personIDs" for domain "person" and was generated for All of Us Controlled Tier Dataset v8
dataset_17343842_person_sql <- paste("
    SELECT
        person.person_id 
    FROM
        `person` person   
    WHERE
        person.PERSON_ID IN (SELECT
            distinct person_id  
        FROM
            `cb_search_person` cb_search_person  
        WHERE
            cb_search_person.person_id IN (SELECT
                person_id 
            FROM
                `cb_search_person` p 
            WHERE
                has_whole_genome_variant = 1 ) )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
person_17343842_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "person_17343842",
  "person_17343842_*.csv")
message(str_glue('The data will be written to {person_17343842_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_17343842_person_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  person_17343842_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {person_17343842_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- NULL
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
dataset_17343842_person_df <- read_bq_export_from_workspace_bucket(person_17343842_path)

dim(dataset_17343842_person_df)

head(dataset_17343842_person_df, 5)

print("unique person IDs of all individuals with sr-WGS data ")
Has_srWGS_all_personIDs <- 
  dataset_17343842_person_df %>%
  # create a column of 1s to signify these individuals have srWGS data
  mutate(
    .data = .,
    srWGS_all_yes = 1
  )

print("number of person IDs in table (not unique)")
Has_srWGS_all_personIDs$person_id %>% length(x = .)
print("number of UNIQUE person IDs")
Has_srWGS_all_personIDs$person_id %>% unique(x = .) %>% length(x = .)

#### sr-WGS person IDs (sex at birth = Female)
library(tidyverse)
library(bigrquery)

# This query represents dataset "VERSION8_Has_srWGS_and_Female_sex_personIDs" for domain "person" and was generated for All of Us Controlled Tier Dataset v8
dataset_21637373_person_sql <- paste("
    SELECT
        person.person_id,
        p_sex_at_birth_concept.concept_name as sex_at_birth 
    FROM
        `person` person 
    LEFT JOIN
        `concept` p_sex_at_birth_concept 
            ON person.sex_at_birth_concept_id = p_sex_at_birth_concept.concept_id  
    WHERE
        person.PERSON_ID IN (SELECT
            distinct person_id  
        FROM
            `cb_search_person` cb_search_person  
        WHERE
            cb_search_person.person_id IN (SELECT
                person_id 
            FROM
                `cb_search_person` p 
            WHERE
                has_whole_genome_variant = 1 ) 
            AND cb_search_person.person_id IN (SELECT
                person_id 
            FROM
                `person` p 
            WHERE
                sex_at_birth_concept_id IN (45878463) ) )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
person_21637373_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "person_21637373",
  "person_21637373_*.csv")
message(str_glue('The data will be written to {person_21637373_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_21637373_person_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  person_21637373_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {person_21637373_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- cols(sex_at_birth = col_character())
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
Has_srWGS_and_Female_sex_personIDs <- read_bq_export_from_workspace_bucket(person_21637373_path)

dim(Has_srWGS_and_Female_sex_personIDs)

head(Has_srWGS_and_Female_sex_personIDs, 5)

# make sure all sex is female
Has_srWGS_and_Female_sex_personIDs$sex_at_birth %>% unique()
# count number of participants (NOT unique)
Has_srWGS_and_Female_sex_personIDs$person_id %>% length()
# number of unique participants
Has_srWGS_and_Female_sex_personIDs$person_id %>% unique() %>% length()

#### survey data person IDs (full AoURP cohort)
library(tidyverse)
library(bigrquery)

# This query represents dataset "Has_survey_all_AoURP_personIDs" for domain "survey" and was generated for All of Us Controlled Tier Dataset v8
dataset_58994155_survey_sql <- paste("
    SELECT
        answer.person_id  
    FROM
        `ds_survey` answer    
    WHERE
        (
            answer.PERSON_ID IN (SELECT
                distinct person_id  
            FROM
                `cb_search_person` cb_search_person  
            WHERE
                cb_search_person.person_id IN (SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (1585855, 43528895, 1333342, 1586134, 1741006, 40192389, 1740639, 1585710)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 0 
                            AND is_selectable = 1) 
                        AND is_standard = 0 )) criteria ) )
        )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
survey_58994155_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "survey_58994155",
  "survey_58994155_*.csv")
message(str_glue('The data will be written to {survey_58994155_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_58994155_survey_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  survey_58994155_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {survey_58994155_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- cols(survey = col_character(), answer = col_character())
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
Has_survey_all_AoURP_personIDs <- read_bq_export_from_workspace_bucket(survey_58994155_path)

dim(Has_survey_all_AoURP_personIDs)

head(Has_survey_all_AoURP_personIDs, 5)

print("unique person IDs of all individuals with SURVEY data ")
Has_survey_all_AoURP_personIDs <- 
  Has_survey_all_AoURP_personIDs %>%
  # create a column of 1s to signify these individuals have SURVEY data
  mutate(
    .data = .,
    survey_all_yes = 1
  )

print("number of person IDs in table (not unique)")
Has_survey_all_AoURP_personIDs$person_id %>% length(x = .)
print("number of UNIQUE person IDs")
Has_survey_all_AoURP_personIDs$person_id %>% unique(x = .) %>% length(x = .)

#### EHR data person IDs (full AoURP cohort)
library(tidyverse)
library(bigrquery)

# This query represents dataset "Has_EHR_all_AoURP_personIDs" for domain "person" and was generated for All of Us Controlled Tier Dataset v8
dataset_71197926_person_sql <- paste("
    SELECT
        person.person_id 
    FROM
        `person` person   
    WHERE
        person.PERSON_ID IN (SELECT
            distinct person_id  
        FROM
            `cb_search_person` cb_search_person  
        WHERE
            cb_search_person.person_id IN (SELECT
                person_id 
            FROM
                `cb_search_person` p 
            WHERE
                has_ehr_data = 1 ) )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
person_71197926_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "person_71197926",
  "person_71197926_*.csv")
message(str_glue('The data will be written to {person_71197926_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_71197926_person_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  person_71197926_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {person_71197926_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- NULL
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
dataset_71197926_person_df <- read_bq_export_from_workspace_bucket(person_71197926_path)

dim(dataset_71197926_person_df)

head(dataset_71197926_person_df, 5)

print("unique person IDs of all individuals with EHR data ")
Has_EHR_all_AoURP_personIDs <- 
  dataset_71197926_person_df %>%
  # create a column of 1s to signify these individuals have EHR data
  mutate(
    .data = .,
    EHR_all_yes = 1
  )

print("number of person IDs in table (not unique)")
Has_EHR_all_AoURP_personIDs$person_id %>% length(x = .)
print("number of UNIQUE person IDs")
Has_EHR_all_AoURP_personIDs$person_id %>% unique(x = .) %>% length(x = .)

# Menopause EHR diagnosis person IDs (full AoURP cohort)
# query information: Has EHR data AND (Conditions: Menopause present OR Premature menopause)

# need ALL individuals that had menopause diagnostic code in EHR (ignoring sr-WGS data)

### query information: Has EHR data AND (Conditions: Menopause present OR Premature menopause)

library(tidyverse)
library(bigrquery)

# This query represents dataset "VERSION8_Has_EHR_MenopauseDiagnosticCode_all_personIDs" for domain "person" and was generated for All of Us Controlled Tier Dataset v8
dataset_84541789_person_sql <- paste("
    SELECT
        person.person_id 
    FROM
        `person` person   
    WHERE
        person.PERSON_ID IN (SELECT
            distinct person_id  
        FROM
            `cb_search_person` cb_search_person  
        WHERE
            cb_search_person.person_id IN (SELECT
                person_id 
            FROM
                `cb_search_person` p 
            WHERE
                has_ehr_data = 1 ) 
            AND cb_search_person.person_id IN (SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `cb_search_all_events` 
                WHERE
                    (concept_id IN (4128329) 
                    AND is_standard = 1 )) criteria 
            UNION
            DISTINCT SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `cb_search_all_events` 
                WHERE
                    (concept_id IN (198715) 
                    AND is_standard = 1 )) criteria ) )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
person_84541789_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "person_84541789",
  "person_84541789_*.csv")
message(str_glue('The data will be written to {person_84541789_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_84541789_person_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  person_84541789_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {person_84541789_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- NULL
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
dataset_84541789_person_df <- read_bq_export_from_workspace_bucket(person_84541789_path)

dim(dataset_84541789_person_df)

head(dataset_84541789_person_df, 5)

Has_EHR_MenopauseDiagnosticCode_all_personIDs <- 
  dataset_84541789_person_df %>%
  # create a column of 1s to signify these individuals have a menopause diagnostic code in the EHR
  ### query information: Has EHR data AND (Conditions: Menopause present OR Premature menopause)
  mutate(
    .data = .,
    EHR_menopauseCode_all_yes = 1
  )

print("number of person IDs in dataset (NOT unique)")
Has_EHR_MenopauseDiagnosticCode_all_personIDs$person_id %>% length(x = .)
print("number of UNIQUE person IDs in dataset")
Has_EHR_MenopauseDiagnosticCode_all_personIDs$person_id %>% unique(x = .) %>% length(x = .)
Has_EHR_MenopauseDiagnosticCode_all_personIDs$EHR_menopauseCode_all_yes %>% sum()

# # Menopause survey question (answer = yes) person IDs (full AoURP cohort)
# # query satisfies condition:
# Yes answer to menopause Survey question: 
#   Have your menstrual periods stopped permanently? - Yes None, 
# OR
# Have your menstrual periods stopped permanently? - Yes But Hormone

# need ALL individuals that answered yes to menopause survey question (ignoring sr-WGS data)
### query satisfies condition: 
# Yes answer to menopause Survey question: 
# Have your menstrual periods stopped permanently? - Yes None, 
# OR
# Have your menstrual periods stopped permanently? - Yes But Hormone


library(tidyverse)
library(bigrquery)

# This query represents dataset "VERSION8_Has_SurveyMenstrualStoppedYes_all_personIDs" for domain "person" and was generated for All of Us Controlled Tier Dataset v8
dataset_70563279_person_sql <- paste("
    SELECT
        person.person_id 
    FROM
        `person` person   
    WHERE
        person.PERSON_ID IN (SELECT
            distinct person_id  
        FROM
            `cb_search_person` cb_search_person  
        WHERE
            cb_search_person.person_id IN (SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `cb_search_all_events` 
                WHERE
                    (concept_id IN (1585784) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585786))) criteria 
            UNION
            DISTINCT SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `cb_search_all_events` 
                WHERE
                    (concept_id IN (1585784) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585787))) criteria ) )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
person_70563279_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "person_70563279",
  "person_70563279_*.csv")
message(str_glue('The data will be written to {person_70563279_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_70563279_person_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  person_70563279_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {person_70563279_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- NULL
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
dataset_70563279_person_df <- read_bq_export_from_workspace_bucket(person_70563279_path)

dim(dataset_70563279_person_df)

head(dataset_70563279_person_df, 5)

### query satisfies condition: 
# Yes answer to menopause Survey question: 
# Have your menstrual periods stopped permanently? - Yes None, 
# OR
# Have your menstrual periods stopped permanently? - Yes But Hormone
Has_SurveyMenopauseQuestionYes_all <-
  dataset_70563279_person_df %>%
  # create a column of 1s to signify these individuals answered yes to survey menopause question
  mutate(
    .data = .,
    Survey_menopauseQuestion_all_yes = 1
  )

print("number NOT unique person IDs")
Has_SurveyMenopauseQuestionYes_all$person_id %>% length(x = .)
print("number UNIQUE person IDs")
Has_SurveyMenopauseQuestionYes_all$person_id %>% unique(x = .) %>% length(x = .)
Has_SurveyMenopauseQuestionYes_all$Survey_menopauseQuestion_all_yes %>% sum()

# # Menopause survey question (any answer) person IDs (full AoURP cohort)
# # query satisfies condition:
  # Surveys | Have your menstrual periods stopped permanently? - Periods Havent Stopped, 
  # Have your menstrual periods stopped permanently? - Yes None, 
  # Have your menstrual periods stopped permanently? - Yes But Hormone, 
  # Have your menstrual periods stopped permanently? - Not Sure Menstrual Stopped, 
  # Have your menstrual periods stopped permanently? - Prefer Not To Answer, 
  # Have your menstrual periods stopped permanently? - Skip

library(tidyverse)
library(bigrquery)

# This query represents dataset "VERSION8_Has_SurveyMenstrualStopped_AnyAnswer_all_personIDs" for domain "survey" and was generated for All of Us Controlled Tier Dataset v8
dataset_11423969_survey_sql <- paste("
    SELECT
        answer.person_id  
    FROM
        `ds_survey` answer   
    WHERE
        (
            question_concept_id IN (1585784)
        )  
        AND (
            answer.PERSON_ID IN (SELECT
                distinct person_id  
            FROM
                `cb_search_person` cb_search_person  
            WHERE
                cb_search_person.person_id IN (SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN (1585784) 
                        AND is_standard = 0  
                        AND  value_source_concept_id IN (1585785) 
                        OR  concept_id IN (1585784) 
                        AND is_standard = 0  
                        AND  value_source_concept_id IN (1585786) 
                        OR  concept_id IN (1585784) 
                        AND is_standard = 0  
                        AND  value_source_concept_id IN (1585787) 
                        OR  concept_id IN (1585784) 
                        AND is_standard = 0  
                        AND  value_source_concept_id IN (1585788) 
                        OR  concept_id IN (1585784) 
                        AND is_standard = 0  
                        AND  value_source_concept_id IN (903079) 
                        OR  concept_id IN (1585784) 
                        AND is_standard = 0  
                        AND  value_source_concept_id IN (903096))) criteria ) )
        )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
survey_11423969_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "survey_11423969",
  "survey_11423969_*.csv")
message(str_glue('The data will be written to {survey_11423969_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_11423969_survey_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  survey_11423969_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {survey_11423969_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- cols(survey = col_character(), question = col_character(), answer = col_character())
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
dataset_11423969_survey_df <- read_bq_export_from_workspace_bucket(survey_11423969_path)

dim(dataset_11423969_survey_df)

head(dataset_11423969_survey_df, 5)

### query satisfies condition: 
#     Surveys | Have your menstrual periods stopped permanently? - Periods Havent Stopped, 
#               Have your menstrual periods stopped permanently? - Yes None, 
#               Have your menstrual periods stopped permanently? - Yes But Hormone, 
#               Have your menstrual periods stopped permanently? - Not Sure Menstrual Stopped, 
#               Have your menstrual periods stopped permanently? - Prefer Not To Answer, 
#               Have your menstrual periods stopped permanently? - Skip

Has_SurveyMenstrualStopped_AnyAnswer_all <-
  dataset_11423969_survey_df %>%
  # create a column of 1s to signify these individuals answered the survey menopause question (any answer)
  mutate(
    .data = .,
    Survey_MenstrualStopped_AnyAnswer_all_yes = 1
  )

print("number NOT unique person IDs")
Has_SurveyMenstrualStopped_AnyAnswer_all$person_id %>% length(x = .)
print("number UNIQUE person IDs")
Has_SurveyMenstrualStopped_AnyAnswer_all$person_id %>% unique(x = .) %>% length(x = .)

# # Calculation of venn diagram overlap for full AoURP cohort
# # grand totals (no menopause information at all):
# (1) srWGS 
# (2) srWGS + female sex
# (3) survey
# (4) EHR
# # 2-way intersect (no menopause):
# srWGS + survey
# srWGS + EHR
# survey + EHR
# # 3-way intersect (no menopause):
# srWGS + survey + EHR
# 
# # totals (menopause):
# (1) EHR Menopause diagnostic code
# (2) Survey Menopause question = ANY answer
# (3) srWGS (female sex)
# # 2-way intersections
# (4) EHR Menopause diagnostic code + Survey Menopause question = ANY answer
# (5) EHR Menopause diagnostic code + srWGS (female sex)
# (6) Survey Menopause question = ANY answer + srWGS (female sex)
# # 3-way intersection
# (7) EHR Menopause diagnostic code + Survey Menopause question = ANY answer + srWGS (female sex)

# Calculation of venn diagram overlap for full AoURP cohort
# grand totals (no menopause information at all):
# (1) srWGS 
Total_srWGS <-
  Has_srWGS_all_personIDs$person_id %>% unique(x = .) %>% length(x = .)
# (2) srWGS + Female sex
Total_srWGS_female_sex <-
  Has_srWGS_and_Female_sex_personIDs$person_id %>% unique(x = .) %>% length(x = .)
# (3) survey
Total_survey_all <- 
  Has_survey_all_AoURP_personIDs$person_id %>% unique(x = .) %>% length(x = .)
# (4) EHR
Total_EHR_all <- 
  Has_EHR_all_AoURP_personIDs$person_id %>% unique(x = .) %>% length(x = .)

# grand 2-way intersections sample sizes (no menopause information at all):
Grand_srWGS_survey <-
  intersect(
    x = Has_srWGS_all_personIDs$person_id,
    y = Has_survey_all_AoURP_personIDs$person_id
  ) %>%
  length(x = .)

Grand_srWGS_EHR <-
  intersect(
    x = Has_srWGS_all_personIDs$person_id,
    y = Has_EHR_all_AoURP_personIDs$person_id
  ) %>%
  length(x = .)

Grand_survey_EHR <-
  intersect(
    x = Has_survey_all_AoURP_personIDs$person_id,
    y = Has_EHR_all_AoURP_personIDs$person_id
  ) %>%
  length(x = .)

# grand 3-way intersection sample size (no menopause information at all)
Grand_srWGS_survey_EHR <-
  intersect(
    x = Has_srWGS_all_personIDs$person_id,
    y = Has_survey_all_AoURP_personIDs$person_id
  ) %>%
  intersect(
    x = .,
    y = Has_EHR_all_AoURP_personIDs$person_id
  ) %>%
  length(x = .)

# menopause totals:
# (1) EHR Menopause diagnostic code
Total_EHR_Menopause_diagnostic_code <- 
  Has_EHR_MenopauseDiagnosticCode_all_personIDs$person_id %>% 
  unique(x = .) %>% 
  length(x = .)
# (2) Survey Menopause question = ANY answer
Total_Survey_Menopause_question_AnyAnswer <-
  Has_SurveyMenstrualStopped_AnyAnswer_all$person_id %>% 
  unique(x = .) %>% 
  length(x = .)
# (3) srWGS (female sex) (calculated above)
Total_srWGS_female_sex

# 2-way menopause intersections
# (4) EHR Menopause diagnostic code + Survey Menopause question = ANY answer
Menopause_EHR_Survey <-
  intersect(
    x = Has_EHR_MenopauseDiagnosticCode_all_personIDs$person_id,
    y = Has_SurveyMenstrualStopped_AnyAnswer_all$person_id
  ) %>%
  length(x = .)
# (5) EHR Menopause diagnostic code + srWGS (female sex)
Menopause_EHR_srWGS <-
  intersect(
    x = Has_EHR_MenopauseDiagnosticCode_all_personIDs$person_id,
    y = Has_srWGS_and_Female_sex_personIDs$person_id
  ) %>% 
  length(x = .)
# (6) Survey Menopause question = ANY answer + srWGS (female sex)
Menopause_Survey_srWGS <-
  intersect(
    x = Has_SurveyMenstrualStopped_AnyAnswer_all$person_id,
    y = Has_srWGS_and_Female_sex_personIDs$person_id
  ) %>% 
  length(x = .)

# 3-way menopause intersection
# (7) EHR Menopause diagnostic code + Survey Menopause question = ANY answer + srWGS (female sex)
Menopause_EHR_Survey_srWGS <- 
  intersect(
    x = Has_EHR_MenopauseDiagnosticCode_all_personIDs$person_id,
    y = Has_SurveyMenstrualStopped_AnyAnswer_all$person_id
  ) %>%
  intersect(
    x = .,
    y = Has_srWGS_and_Female_sex_personIDs$person_id
  ) %>%
  length(x = .)

# put everything into a table for easy viewing
Menopause_IntersectionVenn_Table <-
  data.frame(
    "Category" = c("Total (all, no menopause)",
                   "srWGS",
                   "Survey",
                   "EHR",
                   "2-way intersect (no menopause)",
                   "srWGS + survey", 
                   "srWGS + EHR",
                   "survey + EHR",
                   "3-way intersect (no menopause)",
                   "srWGS + survey + EHR",
                   "Total (menopause)",
                   "EHR Menopause diagnostic code",
                   "Survey Menopause question = ANY answer",
                   "srWGS (female sex)",
                   "2-way intersect (menopause)",
                   "EHR Menopause diagnostic code + Survey Menopause question = ANY answer",
                   "EHR Menopause diagnostic code + srWGS (female sex)",
                   "Survey Menopause question = ANY answer + srWGS (female sex)",
                   "3-way intersect (menopause)",
                   "EHR Menopause diagnostic code + Survey Menopause question = ANY answer + srWGS (female sex)"
    ),
    "Sample_size_N" = c(
      "",
      Total_srWGS,
      Total_survey_all,
      Total_EHR_all,
      "",
      Grand_srWGS_survey, 
      Grand_srWGS_EHR,
      Grand_survey_EHR,
      "",
      Grand_srWGS_survey_EHR,
      "",
      Total_EHR_Menopause_diagnostic_code,
      Total_Survey_Menopause_question_AnyAnswer,
      Total_srWGS_female_sex,
      "",
      Menopause_EHR_Survey,
      Menopause_EHR_srWGS,
      Menopause_Survey_srWGS,
      "",
      Menopause_EHR_Survey_srWGS
    )
  ) %>%
  # convert sample size column to numeric
  mutate(
    .data = .,
    Sample_size_N = Sample_size_N %>% as.numeric(x = .)
  ) %>%
  # if the sample size is < 20, round to 20
  # if the sample size is >=20, round up to nearest 5
  mutate(
    Sample_size_N = case_when(
      Sample_size_N < 20 ~ 20,
      TRUE ~ ceiling(Sample_size_N / 5) * 5
    )
  )

# create a directory for saving menopause summary statistics for poster if it does not exist
if(!dir.exists(paths = "./MenoSummaryStats_CUWHC_poster_VERSION8/"))
{
  dir.create(path = "./MenoSummaryStats_CUWHC_poster_VERSION8/")
}
# show table
Menopause_IntersectionVenn_Table

# # save the table to the file system
# Menopause_IntersectionVenn_Table %>%
# write_tsv(
#     x = .,
#     file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Menopause_IntersectionVenn_Table_V8_freeze09182025.tsv"
# )

# load and view the frozen menopause venn intersection table
Menopause_IntersectionVenn_Table <-
  read.delim(
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Menopause_IntersectionVenn_Table_V8_freeze09182025.tsv",
    header = TRUE
  )

Menopause_IntersectionVenn_Table

# # Granular menopause EHR diagnostic codes and survey responses (broken down by individual diagnostic code and survey question and not aggregated), not intersected with any other dataset
# # Conditions | Abnormal vasomotor function
# OR
# Conditions | Parent Primary ovarian failure
# OR
# Conditions | Menopause present
# OR
# Conditions | Premature menopause
# OR
# Surveys | Have your menstrual periods stopped permanently?
#   OR
# Surveys | Why did your periods stop?
#   OR
# Surveys | Have you ever had a hysterectomy (that is, surgery to remove your uterus or womb)?
#   OR
# Surveys | If Yes to hysterectomy, age at surgery?
#   OR
# Surveys | Have you ever had an ovary removed?
#   OR
# Surveys | If Yes to ovary removal, age at surgery?

library(tidyverse)
library(bigrquery)

# This query represents dataset "VERSION8_Granular_Menopause_EHR_Survey_poster" for domain "condition" and was generated for All of Us Controlled Tier Dataset v8
dataset_97840167_condition_sql <- paste("
    SELECT
        c_occurrence.person_id,
        c_occurrence.condition_concept_id,
        c_standard_concept.concept_name as standard_concept_name,
        c_standard_concept.concept_code as standard_concept_code,
        c_standard_concept.vocabulary_id as standard_vocabulary,
        c_occurrence.condition_start_datetime,
        c_occurrence.condition_end_datetime,
        c_occurrence.condition_type_concept_id,
        c_type.concept_name as condition_type_concept_name,
        c_occurrence.stop_reason,
        c_occurrence.visit_occurrence_id,
        visit.concept_name as visit_occurrence_concept_name,
        c_occurrence.condition_source_value,
        c_occurrence.condition_source_concept_id,
        c_source_concept.concept_name as source_concept_name,
        c_source_concept.concept_code as source_concept_code,
        c_source_concept.vocabulary_id as source_vocabulary,
        c_occurrence.condition_status_source_value,
        c_occurrence.condition_status_concept_id,
        c_status.concept_name as condition_status_concept_name 
    FROM
        ( SELECT
            * 
        FROM
            `condition_occurrence` c_occurrence 
        WHERE
            (
                condition_concept_id IN (SELECT
                    DISTINCT c.concept_id 
                FROM
                    `cb_criteria` c 
                JOIN
                    (SELECT
                        CAST(cr.id as string) AS id       
                    FROM
                        `cb_criteria` cr       
                    WHERE
                        concept_id IN (198715, 4128329, 4279913, 4322635)       
                        AND full_text LIKE '%_rank1]%'      ) a 
                        ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                        OR c.path LIKE CONCAT('%.', a.id) 
                        OR c.path LIKE CONCAT(a.id, '.%') 
                        OR c.path = a.id) 
                WHERE
                    is_standard = 1 
                    AND is_selectable = 1)
            )  
            AND (
                c_occurrence.PERSON_ID IN (SELECT
                    distinct person_id  
                FROM
                    `cb_search_person` cb_search_person  
                WHERE
                    cb_search_person.person_id IN (SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN (4322635) 
                            AND is_standard = 1 )) criteria 
                    UNION
                    DISTINCT SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN(SELECT
                                DISTINCT c.concept_id 
                            FROM
                                `cb_criteria` c 
                            JOIN
                                (SELECT
                                    CAST(cr.id as string) AS id       
                                FROM
                                    `cb_criteria` cr       
                                WHERE
                                    concept_id IN (4279913)       
                                    AND full_text LIKE '%_rank1]%'      ) a 
                                    ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                    OR c.path LIKE CONCAT('%.', a.id) 
                                    OR c.path LIKE CONCAT(a.id, '.%') 
                                    OR c.path = a.id) 
                            WHERE
                                is_standard = 1 
                                AND is_selectable = 1) 
                            AND is_standard = 1 )) criteria 
                    UNION
                    DISTINCT SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN (4128329) 
                            AND is_standard = 1 )) criteria 
                    UNION
                    DISTINCT SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN (198715) 
                            AND is_standard = 1 )) criteria 
                    UNION
                    DISTINCT SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN (3035281) 
                            AND is_standard = 1 )) criteria 
                    UNION
                    DISTINCT SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN(SELECT
                                DISTINCT c.concept_id 
                            FROM
                                `cb_criteria` c 
                            JOIN
                                (SELECT
                                    CAST(cr.id as string) AS id       
                                FROM
                                    `cb_criteria` cr       
                                WHERE
                                    concept_id IN (1585784)       
                                    AND full_text LIKE '%_rank1]%'      ) a 
                                    ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                    OR c.path LIKE CONCAT('%.', a.id) 
                                    OR c.path LIKE CONCAT(a.id, '.%') 
                                    OR c.path = a.id) 
                            WHERE
                                is_standard = 0 
                                AND is_selectable = 1) 
                            AND is_standard = 0 )) criteria 
                    UNION
                    DISTINCT SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN(SELECT
                                DISTINCT c.concept_id 
                            FROM
                                `cb_criteria` c 
                            JOIN
                                (SELECT
                                    CAST(cr.id as string) AS id       
                                FROM
                                    `cb_criteria` cr       
                                WHERE
                                    concept_id IN (1585789)       
                                    AND full_text LIKE '%_rank1]%'      ) a 
                                    ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                    OR c.path LIKE CONCAT('%.', a.id) 
                                    OR c.path LIKE CONCAT(a.id, '.%') 
                                    OR c.path = a.id) 
                            WHERE
                                is_standard = 0 
                                AND is_selectable = 1) 
                            AND is_standard = 0 )) criteria 
                    UNION
                    DISTINCT SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN(SELECT
                                DISTINCT c.concept_id 
                            FROM
                                `cb_criteria` c 
                            JOIN
                                (SELECT
                                    CAST(cr.id as string) AS id       
                                FROM
                                    `cb_criteria` cr       
                                WHERE
                                    concept_id IN (1585791)       
                                    AND full_text LIKE '%_rank1]%'      ) a 
                                    ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                    OR c.path LIKE CONCAT('%.', a.id) 
                                    OR c.path LIKE CONCAT(a.id, '.%') 
                                    OR c.path = a.id) 
                            WHERE
                                is_standard = 0 
                                AND is_selectable = 1) 
                            AND is_standard = 0 )) criteria 
                    UNION
                    DISTINCT SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN(SELECT
                                DISTINCT c.concept_id 
                            FROM
                                `cb_criteria` c 
                            JOIN
                                (SELECT
                                    CAST(cr.id as string) AS id       
                                FROM
                                    `cb_criteria` cr       
                                WHERE
                                    concept_id IN (1585795)       
                                    AND full_text LIKE '%_rank1]%'      ) a 
                                    ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                    OR c.path LIKE CONCAT('%.', a.id) 
                                    OR c.path LIKE CONCAT(a.id, '.%') 
                                    OR c.path = a.id) 
                            WHERE
                                is_standard = 0 
                                AND is_selectable = 1) 
                            AND is_standard = 0 )) criteria 
                    UNION
                    DISTINCT SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN(SELECT
                                DISTINCT c.concept_id 
                            FROM
                                `cb_criteria` c 
                            JOIN
                                (SELECT
                                    CAST(cr.id as string) AS id       
                                FROM
                                    `cb_criteria` cr       
                                WHERE
                                    concept_id IN (1585796)       
                                    AND full_text LIKE '%_rank1]%'      ) a 
                                    ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                    OR c.path LIKE CONCAT('%.', a.id) 
                                    OR c.path LIKE CONCAT(a.id, '.%') 
                                    OR c.path = a.id) 
                            WHERE
                                is_standard = 0 
                                AND is_selectable = 1) 
                            AND is_standard = 0 )) criteria 
                    UNION
                    DISTINCT SELECT
                        criteria.person_id 
                    FROM
                        (SELECT
                            DISTINCT person_id, entry_date, concept_id 
                        FROM
                            `cb_search_all_events` 
                        WHERE
                            (concept_id IN(SELECT
                                DISTINCT c.concept_id 
                            FROM
                                `cb_criteria` c 
                            JOIN
                                (SELECT
                                    CAST(cr.id as string) AS id       
                                FROM
                                    `cb_criteria` cr       
                                WHERE
                                    concept_id IN (1585802)       
                                    AND full_text LIKE '%_rank1]%'      ) a 
                                    ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                    OR c.path LIKE CONCAT('%.', a.id) 
                                    OR c.path LIKE CONCAT(a.id, '.%') 
                                    OR c.path = a.id) 
                            WHERE
                                is_standard = 0 
                                AND is_selectable = 1) 
                            AND is_standard = 0 )) criteria ) )
                )
            ) c_occurrence 
        LEFT JOIN
            `concept` c_standard_concept 
                ON c_occurrence.condition_concept_id = c_standard_concept.concept_id 
        LEFT JOIN
            `concept` c_type 
                ON c_occurrence.condition_type_concept_id = c_type.concept_id 
        LEFT JOIN
            `visit_occurrence` v 
                ON c_occurrence.visit_occurrence_id = v.visit_occurrence_id 
        LEFT JOIN
            `concept` visit 
                ON v.visit_concept_id = visit.concept_id 
        LEFT JOIN
            `concept` c_source_concept 
                ON c_occurrence.condition_source_concept_id = c_source_concept.concept_id 
        LEFT JOIN
            `concept` c_status 
                ON c_occurrence.condition_status_concept_id = c_status.concept_id", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
condition_97840167_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "condition_97840167",
  "condition_97840167_*.csv")
message(str_glue('The data will be written to {condition_97840167_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_97840167_condition_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  condition_97840167_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {condition_97840167_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- cols(standard_concept_name = col_character(), standard_concept_code = col_character(), standard_vocabulary = col_character(), condition_type_concept_name = col_character(), stop_reason = col_character(), visit_occurrence_concept_name = col_character(), condition_source_value = col_character(), source_concept_name = col_character(), source_concept_code = col_character(), source_vocabulary = col_character(), condition_status_source_value = col_character(), condition_status_concept_name = col_character())
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
Granular_Menopause_EHR_condition_data <- read_bq_export_from_workspace_bucket(condition_97840167_path)

dim(Granular_Menopause_EHR_condition_data)

head(Granular_Menopause_EHR_condition_data, 5)
Granular_Menopause_EHR_condition_data %>% names(x = .)
Granular_Menopause_EHR_condition_data$standard_concept_name %>% unique(x = .)

# # save the table to the file system as a data freeze
# Granular_Menopause_EHR_condition_data %>%
# write_tsv(
#     x = .,
#     file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Granular_Menopause_EHR_condition_data_V8_freeze09182025.tsv"
#     )

# read in the granular EHR condition data from the data freeze
Granular_Menopause_EHR_condition_data <-
  read.delim(
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Granular_Menopause_EHR_condition_data_V8_freeze09182025.tsv",
    header = TRUE
  )

Granular_Menopause_EHR_condition_data_clean <-
  Granular_Menopause_EHR_condition_data %>%
  # select useful columns
  select(
    .data = .,
    person_id,
    standard_concept_name:condition_start_datetime
  ) %>%
  # combine concept and vocabulary columns into condition identifier
  mutate(
    .data = .,
    condition_EHR = paste(standard_concept_name,standard_concept_code,standard_vocabulary) %>%
      gsub(pattern = " ",replacement = "_",x = .)
  ) %>%
  # Keep only first instance of each person-condition pair
  group_by(
    .data = .,
    person_id, 
    condition_EHR
  ) %>%
  slice_min(condition_start_datetime, with_ties = FALSE) %>%  # earliest datetime for condition 
  ungroup() %>%
  # Add 1s for one-hot encoding
  mutate(value = 1) 

# Pivot for one-hot encoded values
one_hot_condition <- 
  Granular_Menopause_EHR_condition_data_clean %>%
  select(person_id, condition_EHR, value) %>%
  pivot_wider(
    names_from = condition_EHR,
    values_from = value,
    values_fill = list(value = 0),
    names_prefix = "conditionEHR_"
  )

# Pivot for datetime columns (one date per row that matches the condition)
dates_wide_condition <- 
  Granular_Menopause_EHR_condition_data_clean %>%
  select(person_id, condition_EHR, condition_start_datetime) %>%
  pivot_wider(
    names_from = condition_EHR,
    values_from = condition_start_datetime,
    names_prefix = "date_conditionEHR_"
  )

# Join both wide tables so there is one person ID per row
Granular_Menopause_EHR_condition_data_clean_final_oneHot <- 
  one_hot_condition %>%
  left_join(
    x = .,
    y = dates_wide_condition,
    by = "person_id"
  )

# check for unique person IDs
Granular_Menopause_EHR_condition_data_clean_final_oneHot$person_id %>% unique() %>% length()
Granular_Menopause_EHR_condition_data_clean_final_oneHot %>% nrow()
# column names
Granular_Menopause_EHR_condition_data_clean_final_oneHot %>% names()
# preview dataset
Granular_Menopause_EHR_condition_data_clean_final_oneHot %>% head()

library(tidyverse)
library(bigrquery)

# This query represents dataset "VERSION8_Granular_Menopause_EHR_Survey_poster" for domain "survey" and was generated for All of Us Controlled Tier Dataset v8
dataset_97840167_survey_sql <- paste("
    SELECT
        answer.person_id,
        answer.survey_datetime,
        answer.survey,
        answer.question_concept_id,
        answer.question,
        answer.answer_concept_id,
        answer.answer,
        answer.survey_version_concept_id,
        answer.survey_version_name  
    FROM
        `ds_survey` answer   
    WHERE
        (
            question_concept_id IN (1585784, 1585789, 1585791, 1585795, 1585796, 1585802)
        )  
        AND (
            answer.PERSON_ID IN (SELECT
                distinct person_id  
            FROM
                `cb_search_person` cb_search_person  
            WHERE
                cb_search_person.person_id IN (SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN (4322635) 
                        AND is_standard = 1 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (4279913)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 1 
                            AND is_selectable = 1) 
                        AND is_standard = 1 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN (4128329) 
                        AND is_standard = 1 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN (198715) 
                        AND is_standard = 1 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN (3035281) 
                        AND is_standard = 1 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (1585784)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 0 
                            AND is_selectable = 1) 
                        AND is_standard = 0 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (1585789)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 0 
                            AND is_selectable = 1) 
                        AND is_standard = 0 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (1585791)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 0 
                            AND is_selectable = 1) 
                        AND is_standard = 0 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (1585795)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 0 
                            AND is_selectable = 1) 
                        AND is_standard = 0 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (1585796)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 0 
                            AND is_selectable = 1) 
                        AND is_standard = 0 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (1585802)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 0 
                            AND is_selectable = 1) 
                        AND is_standard = 0 )) criteria ) )
            )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
survey_97840167_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "survey_97840167",
  "survey_97840167_*.csv")
message(str_glue('The data will be written to {survey_97840167_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_97840167_survey_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  survey_97840167_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {survey_97840167_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- cols(survey = col_character(), question = col_character(), answer = col_character(), survey_version_name = col_character())
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
Granular_Menopause_Survey_Response <- read_bq_export_from_workspace_bucket(survey_97840167_path)

dim(Granular_Menopause_Survey_Response)

head(Granular_Menopause_Survey_Response, 5)

# # save the file to the file system as a datafreeze
# Granular_Menopause_Survey_Response %>%
# write_tsv(
#     x = .,
#     file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Granular_Menopause_Survey_Response_V8_freeze09182025.tsv"
# )

Granular_Menopause_Survey_Response <-
  read.delim(
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Granular_Menopause_Survey_Response_V8_freeze09182025.tsv"
  )

# obtain Overall Health Ovary Removal History Age and Overall Health: Hysterectomy History Age
# as well as those that answered yes to ovary removal history and hysterectomy history


# prepare and combine question-answer pairs for one-hot encoding 
Granular_Menopause_Survey_Response_clean <-
  Granular_Menopause_Survey_Response %>% 
  # filter out age questions
  filter(
    .data = .,
    question!= 'Overall Health Ovary Removal History Age'
  ) %>%
  filter(
    .data = .,
    question!='Overall Health: Hysterectomy History Age'
  ) %>%
  # select useful columns
  select(
    .data = .,
    person_id,
    question,
    answer,
    survey_datetime
  ) %>%
  # remove any colon (:) from the question and answer column
  mutate(
    .data = .,
    question = question %>%
      sub(pattern = ":",replacement = "",x = .),
    answer = answer %>%
      sub(pattern = ":",replacement = "",x = .)
  ) %>%
  # Create one-hot identifier: "question_answer"
  mutate(
    .data = .,
    question_answer = paste(question, answer, sep = "_") %>%
      gsub(pattern = " ",replacement = "_",x = .)
  ) %>%
  # Select earliest survey_datetime per person-question_answer pair
  group_by(
    .data = .,
    person_id, 
    question_answer
  ) %>%
  slice_min(survey_datetime, with_ties = FALSE) %>%
  ungroup(x = .) %>%
  # Add value column for one-hot encoding
  mutate(
    .data = .,
    value = 1
  )

# Pivot to wide format for one-hot question_answer values
survey_onehot <- 
  Granular_Menopause_Survey_Response_clean %>%
  select(person_id, question_answer, value) %>%
  pivot_wider(
    names_from = question_answer,
    values_from = value,
    values_fill = list(value = 0),
    names_prefix = "surveyQ_"
  )

# Pivot to wide format for earliest survey datetimes
survey_dates <- 
  Granular_Menopause_Survey_Response_clean %>%
  select(person_id, question_answer, survey_datetime) %>%
  pivot_wider(
    names_from = question_answer,
    values_from = survey_datetime,
    names_prefix = "date_surveyQ_"
  )

# Join one-hot values and date columns into final survey table
Granular_Menopause_Survey_Response_clean_final_oneHot <- 
  survey_onehot %>%
  left_join(
    x = .,
    y = survey_dates,
    by = "person_id"
  )

Granular_Menopause_Survey_Response <-
  read.delim(
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Granular_Menopause_Survey_Response_V8_freeze09182025.tsv"
  )

# obtain Overall Health Ovary Removal History Age and Overall Health: Hysterectomy History Age
# as well as those that answered ovary removal history and hysterectomy history questions
Granular_Menopause_Survey_Response %>% names()
Granular_Menopause_Survey_Response$question %>% unique(x = .)

Survey_ovary_hysterectomy_data <-
  Granular_Menopause_Survey_Response %>%
  filter(
    .data = .,
    # filter the data to relevant surgery questions
    question %in% 
      c(
        "Overall Health: Hysterectomy History",
        #"Overall Health: Hysterectomy History Age",
        "Overall Health: Ovary Removal History"#,
        #"Overall Health Ovary Removal History Age"
      )
  ) %>%
  # select useful columns
  select(
    .data = .,
    person_id,
    question,
    answer,
    survey_datetime
  ) %>%
  # remove any colon (:) from the question and answer column
  mutate(
    .data = .,
    question = question %>%
      sub(pattern = ":",replacement = "",x = .),
    answer = answer %>%
      sub(pattern = ":",replacement = "",x = .)
  ) %>%
  # Create one-hot identifier: "question_answer"
  mutate(
    .data = .,
    question_answer = paste(question, answer, sep = "_") %>%
      gsub(pattern = " ",replacement = "_",x = .)
  ) %>%
  # Select earliest survey_datetime per person-question_answer pair
  group_by(
    .data = .,
    person_id, 
    question_answer
  ) %>%
  slice_min(survey_datetime, with_ties = FALSE) %>%
  ungroup(x = .) %>%
  # Add value column for one-hot encoding
  mutate(
    .data = .,
    value = 1
  )

# Pivot to wide format for one-hot question_answer values
survey_onehot <- 
  Survey_ovary_hysterectomy_data %>%
  select(person_id, question_answer, value) %>%
  pivot_wider(
    names_from = question_answer,
    values_from = value,
    values_fill = list(value = 0),
    names_prefix = "surveyQ_"
  )

# Pivot to wide format for earliest survey datetimes
survey_dates <- 
  Survey_ovary_hysterectomy_data %>%
  select(person_id, question_answer, survey_datetime) %>%
  pivot_wider(
    names_from = question_answer,
    values_from = survey_datetime,
    names_prefix = "date_surveyQ_"
  )

# Join one-hot values and date columns into final survey table
Survey_ovary_hysterectomy_data_clean_final_oneHot <- 
  survey_onehot %>%
  left_join(
    x = .,
    y = survey_dates,
    by = "person_id"
  )

Survey_ovary_hysterectomy_data_clean_final_oneHot %>%
  head()

print(nrow(Survey_ovary_hysterectomy_data_clean_final_oneHot))

# obtain ovary removal and hysterectomy age data that matches the questions/answer combinations that are
# being included in the analysis
OvaryRemovalAndHysterectomyAgeData <- 
  Survey_ovary_hysterectomy_data_clean_final_oneHot %>%
  # create a non-missing date time column for the ovary removal and hysterectomy
  mutate(
    .data = .,
    # ovary 
    NonMissing_OvaryRemove_datetime =
      do.call(
        dplyr::coalesce,
        pick(starts_with("date_surveyQ_Overall_Health_Ovary"))
      ),
    # hysterectomy
    NonMissing_Hysterectomy_datetime =
      do.call(
        dplyr::coalesce,
        pick(starts_with("date_surveyQ_Overall_Health_Hysterectomy"))
      )
  ) %>%
  # append the person_id to the non-missing date time column for the ovary removal and hysterectomy
  mutate(
    .data = .,
    person_id_NonMissing_OvaryRemove_datetime = paste0(person_id,"_",NonMissing_OvaryRemove_datetime),
    person_id_NonMissing_Hysterectomy_datetime = paste0(person_id,"_",NonMissing_Hysterectomy_datetime)
  ) %>%
  # join with the responses to the ovary removal age question based on the same person_id and datetime of the answer
  left_join(
    x = .,
    y = Granular_Menopause_Survey_Response %>%
      # filter to ovary removal age question
      filter(
        .data = .,
        question=="Overall Health Ovary Removal History Age"
      ) %>%
      # select useful columns
      select(
        .data = .,
        person_id,
        answer,
        survey_datetime
      ) %>%
      # combine the person_id and survey_datetime column for joining with the other table
      mutate(
        .data = .,
        person_id_survey_datetime = paste0(person_id,"_",survey_datetime)
      ) %>%
      # select useful columns
      select(
        .data = .,
        person_id_survey_datetime,
        "OvaryRemoveAge" = answer
      ),
    by = c("person_id_NonMissing_OvaryRemove_datetime" = "person_id_survey_datetime")
  ) %>%
  # join with the responses to the hysterectomy age question based on the same person_id 
  # and datetime of the answer
  left_join(
    x = .,
    y = Granular_Menopause_Survey_Response %>%
      # filter to hysterectomy age question
      filter(
        .data = .,
        question=="Overall Health: Hysterectomy History Age"
      ) %>%
      # select useful columns
      select(
        .data = .,
        person_id,
        answer,
        survey_datetime
      ) %>%
      # combine the person_id and survey_datetime column for joining with the other table
      mutate(
        .data = .,
        person_id_survey_datetime = paste0(person_id,"_",survey_datetime)
      ) %>%
      # select useful columns
      select(
        .data = .,
        person_id_survey_datetime,
        "HysterectomyAge" = answer
      ),
    by = c("person_id_NonMissing_Hysterectomy_datetime" = "person_id_survey_datetime")
  ) 

# # save the file to the file system (matching the date of when the data used to create it was frozen)
# OvaryRemovalAndHysterectomyAgeData %>%
# write_tsv(
#         x = .,
#         file = "./MenoSummaryStats_CUWHC_poster_VERSION8/OvaryRemovalAndHysterectomyAgeData_V8_freeze09182025.tsv"
#         )

OvaryRemovalAndHysterectomyAgeData <- 
  read.delim(
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/OvaryRemovalAndHysterectomyAgeData_V8_freeze09182025.tsv",
  )

OvaryRemovalAndHysterectomyAgeData %>% head(x = .)

library(tidyverse)

# using the survey self-reported Ovary Removal and Hysterectomy Ages,
# calculate descriptive statistics (Q1, Median, Q3, and IQR) for female individuals
# and sample sizes of individuals that reported a non-missing numeric age

OvaryRemovalAndHysterectomyAgeData <- 
  read.delim(
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/OvaryRemovalAndHysterectomyAgeData_V8_freeze09182025.tsv",
  )

OvaryRemoveAgeData <-
  OvaryRemovalAndHysterectomyAgeData %>%
  select(
    .data = .,
    person_id,
    OvaryRemoveAge
  ) %>%
  # remove missing values
  filter(
    .data = .,
    (
      OvaryRemoveAge!="PMI: Skip" & 
        !is.na(x = OvaryRemoveAge) & 
        OvaryRemoveAge!="Response removed due to invalid value"
    )
  ) %>%
  # convert to numeric vector
  mutate(
    .data = .,
    OvaryRemoveAge = OvaryRemoveAge %>% 
      as.numeric(x = .)
  ) %>%
  # filter to values age 18 or older
  filter(
    .data = .,
    OvaryRemoveAge >= 18
  )

OvaryRemoveAgeData %>%
  head()

HysterectomyAgeData <-
  OvaryRemovalAndHysterectomyAgeData %>%
  select(
    .data = .,
    person_id,
    HysterectomyAge
  ) %>%
  # remove missing values
  filter(
    .data = .,
    (
      HysterectomyAge!="PMI: Skip" & 
        !is.na(x = HysterectomyAge) & 
        HysterectomyAge!="Response removed due to invalid value"
    )
  ) %>%
  # convert to numeric vector
  mutate(
    .data = .,
    HysterectomyAge = HysterectomyAge %>% 
      as.numeric(x = .)
  ) %>%
  # filter to values age 18 or older
  filter(
    .data = .,
    HysterectomyAge >= 18
  )

HysterectomyAgeData %>%
  head(x = .)

# count number of person IDs
Granular_Menopause_Survey_Response_clean_final_oneHot$person_id %>% unique() %>% length()
Granular_Menopause_Survey_Response_clean_final_oneHot %>% nrow()
# column names
Granular_Menopause_Survey_Response_clean_final_oneHot %>% names()
# preview dataset
Granular_Menopause_Survey_Response_clean_final_oneHot %>% head()

# # Demographic data person IDs (full AoURP cohort)
# #### satisfies query (all demographic, income, and education)
# # Demographics | Current Age In Range 18 - 124
# OR
# Demographics | Ethnicity - Not Hispanic or Latino, Ethnicity - Hispanic or Latino, Ethnicity - Skip, Ethnicity - Race Ethnicity None Of These, Ethnicity - Prefer Not To Answer, Ethnicity - No matching concept
# OR
# Demographics | Gender Identity - Woman, Gender Identity - Man, Gender Identity - Skip, Gender Identity - Not man only, not woman only, prefer not to answer, or skipped, Gender Identity - Non Binary, Gender Identity - I prefer not to answer, Gender Identity - Transgender, Gender Identity - Additional Options, Gender Identity - Unknown
# OR
# Demographics | Race - White, Race - Black or African American, Race - None Indicated, Race - Asian, Race - Skip, Race - More than one population, Race - None of these, Race - I prefer not to answer, Race - Middle Eastern or North African, Race - Native Hawaiian or Other Pacific Islander
# OR
# Demographics | Sex Assigned at Birth - Female, Sex Assigned at Birth - Male, Sex Assigned at Birth - Unknown, Sex Assigned at Birth - Skip, Sex Assigned at Birth - I prefer not to answer, Sex Assigned at Birth - None, Sex Assigned at Birth - Intersex
# OR
# Demographics | Deceased
# OR
# Surveys | What is your annual household income from all sources?
#   OR
# Surveys | What is the highest grade or year of school you completed?

library(tidyverse)
library(bigrquery)

# This query represents dataset "VERSION8_HasDemographic_all_AoURP" for domain "person" and was generated for All of Us Controlled Tier Dataset v8
dataset_36296466_person_sql <- paste("
    SELECT
        person.person_id,
        person.gender_concept_id,
        p_gender_concept.concept_name as gender,
        person.birth_datetime as date_of_birth,
        person.race_concept_id,
        p_race_concept.concept_name as race,
        person.ethnicity_concept_id,
        p_ethnicity_concept.concept_name as ethnicity,
        person.sex_at_birth_concept_id,
        p_sex_at_birth_concept.concept_name as sex_at_birth,
        person.self_reported_category_concept_id,
        p_self_reported_category_concept.concept_name as self_reported_category 
    FROM
        `person` person 
    LEFT JOIN
        `concept` p_gender_concept 
            ON person.gender_concept_id = p_gender_concept.concept_id 
    LEFT JOIN
        `concept` p_race_concept 
            ON person.race_concept_id = p_race_concept.concept_id 
    LEFT JOIN
        `concept` p_ethnicity_concept 
            ON person.ethnicity_concept_id = p_ethnicity_concept.concept_id 
    LEFT JOIN
        `concept` p_sex_at_birth_concept 
            ON person.sex_at_birth_concept_id = p_sex_at_birth_concept.concept_id 
    LEFT JOIN
        `concept` p_self_reported_category_concept 
            ON person.self_reported_category_concept_id = p_self_reported_category_concept.concept_id  
    WHERE
        person.PERSON_ID IN (SELECT
            distinct person_id  
        FROM
            `cb_search_person` cb_search_person  
        WHERE
            cb_search_person.person_id IN (SELECT
                person_id 
            FROM
                `cb_search_person` p 
            WHERE
                DATE_DIFF(CURRENT_DATE, dob, YEAR) - IF(EXTRACT(MONTH FROM dob)*100 + EXTRACT(DAY FROM dob) > EXTRACT(MONTH FROM CURRENT_DATE)*100 + EXTRACT(DAY FROM CURRENT_DATE), 1, 0) BETWEEN 18 AND 124 
                AND NOT EXISTS (      SELECT
                    'x'      
                FROM
                    `death` d      
                WHERE
                    d.person_id = p.person_id ) 
            UNION
            DISTINCT SELECT
                person_id 
            FROM
                `person` p 
            WHERE
                ethnicity_concept_id IN (38003564, 38003563, 903096, 1586148, 903079, 0) 
            UNION
            DISTINCT SELECT
                person_id 
            FROM
                `person` p 
            WHERE
                gender_concept_id IN (45878463, 45880669, 903096, 2000000002, 1585841, 1585842, 1177221, 1585843, 0) 
            UNION
            DISTINCT SELECT
                person_id 
            FROM
                `person` p 
            WHERE
                race_concept_id IN (8527, 8516, 2100000001, 2000000008, 8515, 8657, 903096, 45882607, 38003615, 1177221, 8557) 
            UNION
            DISTINCT SELECT
                person_id 
            FROM
                `person` p 
            WHERE
                sex_at_birth_concept_id IN (45878463, 45880669, 903096, 1177221, 0, 1585849, 46273637) 
            UNION
            DISTINCT SELECT
                person_id 
            FROM
                `person` p 
            WHERE
                EXISTS (      SELECT
                    'x'      
                FROM
                    `death` d      
                WHERE
                    d.person_id = p.person_id ) 
            UNION
            DISTINCT SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `cb_search_all_events` 
                WHERE
                    (concept_id IN(SELECT
                        DISTINCT c.concept_id 
                    FROM
                        `cb_criteria` c 
                    JOIN
                        (SELECT
                            CAST(cr.id as string) AS id       
                        FROM
                            `cb_criteria` cr       
                        WHERE
                            concept_id IN (1585375)       
                            AND full_text LIKE '%_rank1]%'      ) a 
                            ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                            OR c.path LIKE CONCAT('%.', a.id) 
                            OR c.path LIKE CONCAT(a.id, '.%') 
                            OR c.path = a.id) 
                    WHERE
                        is_standard = 0 
                        AND is_selectable = 1) 
                    AND is_standard = 0 )) criteria 
            UNION
            DISTINCT SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `cb_search_all_events` 
                WHERE
                    (concept_id IN(SELECT
                        DISTINCT c.concept_id 
                    FROM
                        `cb_criteria` c 
                    JOIN
                        (SELECT
                            CAST(cr.id as string) AS id       
                        FROM
                            `cb_criteria` cr       
                        WHERE
                            concept_id IN (1585940)       
                            AND full_text LIKE '%_rank1]%'      ) a 
                            ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                            OR c.path LIKE CONCAT('%.', a.id) 
                            OR c.path LIKE CONCAT(a.id, '.%') 
                            OR c.path = a.id) 
                    WHERE
                        is_standard = 0 
                        AND is_selectable = 1) 
                    AND is_standard = 0 )) criteria ) )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
person_36296466_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "person_36296466",
  "person_36296466_*.csv")
message(str_glue('The data will be written to {person_36296466_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_36296466_person_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  person_36296466_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {person_36296466_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- cols(gender = col_character(), race = col_character(), ethnicity = col_character(), sex_at_birth = col_character(), self_reported_category = col_character())
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
dataset_36296466_person_df <- read_bq_export_from_workspace_bucket(person_36296466_path)

dim(dataset_36296466_person_df)

head(dataset_36296466_person_df, 5)

library(tidyverse)
library(bigrquery)

# This query represents dataset "VERSION8_HasDemographic_all_AoURP" for domain "survey" and was generated for All of Us Controlled Tier Dataset v8
dataset_36296466_survey_sql <- paste("
    SELECT
        answer.person_id,
        answer.survey_datetime,
        answer.survey,
        answer.question_concept_id,
        answer.question,
        answer.answer_concept_id,
        answer.answer,
        answer.survey_version_concept_id,
        answer.survey_version_name  
    FROM
        `ds_survey` answer   
    WHERE
        (
            question_concept_id IN (1585375, 1585940)
        )  
        AND (
            answer.PERSON_ID IN (SELECT
                distinct person_id  
            FROM
                `cb_search_person` cb_search_person  
            WHERE
                cb_search_person.person_id IN (SELECT
                    person_id 
                FROM
                    `cb_search_person` p 
                WHERE
                    DATE_DIFF(CURRENT_DATE, dob, YEAR) - IF(EXTRACT(MONTH FROM dob)*100 + EXTRACT(DAY FROM dob) > EXTRACT(MONTH FROM CURRENT_DATE)*100 + EXTRACT(DAY FROM CURRENT_DATE), 1, 0) BETWEEN 18 AND 124 
                    AND NOT EXISTS (      SELECT
                        'x'      
                    FROM
                        `death` d      
                    WHERE
                        d.person_id = p.person_id ) 
                UNION
                DISTINCT SELECT
                    person_id 
                FROM
                    `person` p 
                WHERE
                    ethnicity_concept_id IN (38003564, 38003563, 903096, 1586148, 903079, 0) 
                UNION
                DISTINCT SELECT
                    person_id 
                FROM
                    `person` p 
                WHERE
                    gender_concept_id IN (45878463, 45880669, 903096, 2000000002, 1585841, 1585842, 1177221, 1585843, 0) 
                UNION
                DISTINCT SELECT
                    person_id 
                FROM
                    `person` p 
                WHERE
                    race_concept_id IN (8527, 8516, 2100000001, 2000000008, 8515, 8657, 903096, 45882607, 38003615, 1177221, 8557) 
                UNION
                DISTINCT SELECT
                    person_id 
                FROM
                    `person` p 
                WHERE
                    sex_at_birth_concept_id IN (45878463, 45880669, 903096, 1177221, 0, 1585849, 46273637) 
                UNION
                DISTINCT SELECT
                    person_id 
                FROM
                    `person` p 
                WHERE
                    EXISTS (      SELECT
                        'x'      
                    FROM
                        `death` d      
                    WHERE
                        d.person_id = p.person_id ) 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (1585375)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 0 
                            AND is_selectable = 1) 
                        AND is_standard = 0 )) criteria 
                UNION
                DISTINCT SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (1585940)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 0 
                            AND is_selectable = 1) 
                        AND is_standard = 0 )) criteria ) )
            )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
survey_36296466_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "survey_36296466",
  "survey_36296466_*.csv")
message(str_glue('The data will be written to {survey_36296466_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_36296466_survey_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  survey_36296466_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {survey_36296466_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- cols(survey = col_character(), question = col_character(), answer = col_character(), survey_version_name = col_character())
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}
dataset_36296466_survey_df <- read_bq_export_from_workspace_bucket(survey_36296466_path)

dim(dataset_36296466_survey_df)

head(dataset_36296466_survey_df, 5)

# # Insurance
# satisfies query
# Surveys | 
#   
#   (1) What kind of health insurance or health care coverage do you have? Include those that pay for only one type of service (nursing home care, accidents, or dental care). Exclude private plans that only provide extra cash while hospitalized. If you have more than one kind of health insurance, mark all plans that you have., 
# 
# (2) Are you covered by health insurance or some other kind of health care plan?, 
# 
# (3) Are you currently covered by any of the following types of health insurance or health coverage plans? Select all that apply from one group.
# 

library(tidyverse)
library(bigrquery)

# This query represents dataset "insurance_data_basic_survey_for_menopause" for domain "survey" and was generated for All of Us Controlled Tier Dataset v8
dataset_62672117_survey_sql <- paste("
    SELECT
        answer.person_id,
        answer.survey_datetime,
        answer.question_concept_id,
        answer.question,
        answer.answer_concept_id,
        answer.answer  
    FROM
        `ds_survey` answer   
    WHERE
        (
            question_concept_id IN (1585386, 1585389, 43528428)
        )  
        AND (
            answer.PERSON_ID IN (SELECT
                distinct person_id  
            FROM
                `cb_search_person` cb_search_person  
            WHERE
                cb_search_person.person_id IN (SELECT
                    criteria.person_id 
                FROM
                    (SELECT
                        DISTINCT person_id, entry_date, concept_id 
                    FROM
                        `cb_search_all_events` 
                    WHERE
                        (concept_id IN(SELECT
                            DISTINCT c.concept_id 
                        FROM
                            `cb_criteria` c 
                        JOIN
                            (SELECT
                                CAST(cr.id as string) AS id       
                            FROM
                                `cb_criteria` cr       
                            WHERE
                                concept_id IN (1585389, 1585386, 43528428)       
                                AND full_text LIKE '%_rank1]%'      ) a 
                                ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                                OR c.path LIKE CONCAT('%.', a.id) 
                                OR c.path LIKE CONCAT(a.id, '.%') 
                                OR c.path = a.id) 
                        WHERE
                            is_standard = 0 
                            AND is_selectable = 1) 
                        AND is_standard = 0 )) criteria ) )
        )", sep="")

# Formulate a Cloud Storage destination path for the data exported from BigQuery.
# NOTE: By default data exported multiple times on the same day will overwrite older copies.
#       But data exported on a different days will write to a new location so that historical
#       copies can be kept as the dataset definition is changed.
survey_62672117_path <- file.path(
  Sys.getenv("WORKSPACE_BUCKET"),
  "bq_exports",
  Sys.getenv("OWNER_EMAIL"),
  strftime(lubridate::now(), "%Y%m%d"),  # Comment out this line if you want the export to always overwrite.
  "survey_62672117",
  "survey_62672117_*.csv")
message(str_glue('The data will be written to {survey_62672117_path}. Use this path when reading ',
                 'the data into your notebooks in the future.'))

# Perform the query and export the dataset to Cloud Storage as CSV files.
# NOTE: You only need to run `bq_table_save` once. After that, you can
#       just read data from the CSVs in Cloud Storage.
bq_table_save(
  bq_dataset_query(Sys.getenv("WORKSPACE_CDR"), dataset_62672117_survey_sql, billing = Sys.getenv("GOOGLE_PROJECT")),
  survey_62672117_path,
  destination_format = "CSV")


# Read the data directly from Cloud Storage into memory.
# NOTE: Alternatively you can `gsutil -m cp {survey_62672117_path}` to copy these files
#       to the Jupyter disk.
read_bq_export_from_workspace_bucket <- function(export_path) {
  col_types <- cols(survey = col_character(), question = col_character(), answer = col_character())
  bind_rows(
    map(system2('gsutil', args = c('ls', export_path), stdout = TRUE, stderr = TRUE),
        function(csv) {
          message(str_glue('Loading {csv}.'))
          chunk <- read_csv(pipe(str_glue('gsutil cat {csv}')), col_types = col_types, show_col_types = FALSE)
          if (is.null(col_types)) {
            col_types <- spec(chunk)
          }
          chunk
        }))
}

insurance_basic_survey_df <- read_bq_export_from_workspace_bucket(survey_62672117_path)

dim(insurance_basic_survey_df)

head(insurance_basic_survey_df, 5)


insurance_basic_survey_df_clean <-
  insurance_basic_survey_df %>%
  select(
    .data = .,
    person_id,
    "insurance_basic_survey_datetime" = survey_datetime,
    question,
    answer
  ) %>%
  # clean the question and answer text
  mutate(
    .data = .,
    question = question %>%
      gsub(
        pattern = "^Insurance: |^Health Insurance: ",
        replacement = "",
        x = .
      ) %>%
      gsub(
        pattern = " ",
        replacement = "_",
        x = .
      ),
    answer = answer %>%
      gsub(
        pattern = "^PMI: |^Health Insurance: |^Health Insurance Type: ",
        replacement = "",
        x = .
      )
  ) %>%
  filter(
    .data = .,
    question=="Health_Insurance" | question=="Health_Insurance_Type"
  ) %>%
  # Keep earliest datetime per person-question pair
  group_by(
    .data = .,
    person_id, 
    question
  ) %>%
  slice_min(
    insurance_basic_survey_datetime, 
    with_ties = FALSE
  ) %>%
  ungroup() %>%
  # Pivot wider for values and datetime
  pivot_wider(
    names_from = question,
    values_from = answer
  )

insurance_basic_survey_df_clean %>%
  head()

insurance_basic_survey_df_clean$Health_Insurance %>% unique()
insurance_basic_survey_df_clean$Health_Insurance_Type %>% unique()

demographic_income_education_survey_clean <-
  dataset_36296466_survey_df %>%
  select(
    .data = .,
    person_id,
    "demographic_survey_datetime" = survey_datetime,
    question,
    answer
  ) %>%
  # Clean question text
  mutate(
    .data = .,
    question = question %>%
      gsub(pattern = "Income: Annual Income",replacement = "Income",x = .) %>%
      gsub(pattern = "Education Level: Highest Grade",replacement = "Education",x = .)
  ) %>%
  # Filter only Income and Education questions
  filter(
    .data = .,
    question %in% c("Income", "Education")
  ) %>%
  # Keep earliest datetime per person-question pair
  group_by(
    .data = .,
    person_id, 
    question
  ) %>%
  slice_min(demographic_survey_datetime, with_ties = FALSE) %>%
  ungroup() %>%
  # Pivot wider for values and datetime
  pivot_wider(
    names_from = question,
    values_from = answer
  ) %>%
  left_join(
    x = .,
    y = dataset_36296466_survey_df %>%
      select(
        .data = .,
        person_id,
        "demographic_survey_datetime" = survey_datetime,
        question
      ) %>%
      mutate(
        .data = .,
        question = question %>%
          gsub(pattern = "Income: Annual Income",replacement = "Income",x = .) %>%
          gsub(pattern = "Education Level: Highest Grade",replacement = "Education",x = .)
      ) %>%
      filter(
        .data = .,
        question %in% c("Income", "Education")
      ) %>%
      group_by(
        .data = .,
        person_id, 
        question
      ) %>%
      slice_min(demographic_survey_datetime, with_ties = FALSE) %>%
      ungroup() %>%
      pivot_wider(
        names_from = question,
        values_from = demographic_survey_datetime,
        names_prefix = "date_"
      ),
    by = "person_id"
  )

demographic_income_education_survey_clean$person_id %>% unique() %>% length()
demographic_income_education_survey_clean %>% nrow()
demographic_income_education_survey_clean %>% names()
demographic_income_education_survey_clean %>% head()

# load the genetic ancestry data (determined by principal components)
library(tidyverse)

Ancestry_table <- 
  read.delim(
    file = "./ancestry_preds.tsv",
    header = TRUE
  ) %>%
  select(
    .data = .,
    "person_id" = research_id,
    ancestry_pred
  ) 

Ancestry_table %>%
  head()

# define function for calculating age at a given reference date
# rounded down to nearest year (if a full year has not passed yet, no decimals)
# This function calculates age in complete years at a given event date,
# subtracting one year if the birthday hasn't occurred yet that year
# function returns a numeric vector of age in years, consistent with how individuals report age
calculate_age <- 
  function(
    event_date = NULL, # event_date A Date vector representing the reference date (e.g., survey or observation date)
    birth_date = NULL # birth_date A Date vector representing the participant's date of birth
  ) 
  {
    # Extract the difference in years between the event and birth dates
    age_years <- year(event_date) - year(as_datetime(birth_date))
    
    # Determine if the birthday has NOT occurred yet in the event year
    birthday_not_yet_occurred <- 
      month(event_date) < month(as_datetime(birth_date)) |
      (month(event_date) == month(as_datetime(birth_date)) &
         day(event_date) < day(as_datetime(birth_date)))
    
    # Subtract 1 from age if birthday hasn't occurred yet, otherwise subtract 0
    adjusted_age <- age_years - if_else(birthday_not_yet_occurred, 1, 0)
    
    # Return the final age in years
    return(adjusted_age)
  }

Demographic_data_all_AoURP <-
  # join the full AOURP demographic dataset with income and education data, sr-WGS and priority EHR menopause and survey menopause data
  list(
    # demographic data (age, sex, gender, ethnicity, race)
    dataset_36296466_person_df,
    # income and education demographic data
    demographic_income_education_survey_clean,
    # insurance information
    insurance_basic_survey_df_clean,
    #sr-WGS full AOURP
    Has_srWGS_all_personIDs,
    # genetic ancestry data
    Ancestry_table,
    # has EHR data full AoURP (not menopause specific, just EHR in general)
    Has_EHR_all_AoURP_personIDs,
    # has survey data full AoURP (not menopause specific, just survey in general)
    unique(x = Has_survey_all_AoURP_personIDs),
    # Menopause EHR full AOURP: 
    # query information: Has EHR data AND (Conditions: Menopause present OR Premature menopause)
    Has_EHR_MenopauseDiagnosticCode_all_personIDs,
    # Menopause survey question = yes full AOURP
    # query satisfies condition:
    #Yes answer to menopause Survey question: 
    #Have your menstrual periods stopped permanently? - Yes None, 
    #OR
    #Have your menstrual periods stopped permanently? - Yes But Hormone
    Has_SurveyMenopauseQuestionYes_all,
    # granular menopause EHR diagnostic codes conditions
    Granular_Menopause_EHR_condition_data_clean_final_oneHot,
    # granular menopause survey responses
    Granular_Menopause_Survey_Response_clean_final_oneHot
  ) %>%
  # join all tables by person ID
  reduce(
    .x = .,
    .f = full_join,
    by = "person_id"
  ) %>%
  # replace missing NA values with 0 for one-hot encoded columns that were joined
  mutate(
    .data = .,
    across(
      .cols = all_of(
        
        x = c(
          # more general total one-hot encoded AOURP columns
          "srWGS_all_yes",
          "EHR_menopauseCode_all_yes",
          "Survey_menopauseQuestion_all_yes",
          # dynamic: all granular level variable columns 
          # starting with "conditionEHR_" or "surveyQ_"
          names(.)[startsWith(names(.), "conditionEHR_")],
          names(.)[startsWith(names(.), "surveyQ_")]
        )
      ), 
      .fns = ~ replace_na(.x, 0)
    )
  ) %>%
  # create a column with all values set to 1 for individuals that have demographic data
  # so the demographic characteristics of ALL AoURP participants can be summarized with the rest of the 
  # one-hot encoded variables
  mutate(
    .data = .,
    Demographic_AoURP_all_yes = as.numeric(x = 1)
  ) %>%
  # calculate a combined column for 2-way and 3-way intersections of: 
  # (1) srWGS_all_yes, 
  # (2) EHR_menopauseCode_all_yes, 
  # (3) Survey_menopauseQuestion_all_yes
  mutate(
    .data = .,
    intersect2_srWGS_EHR_menopauseCode_all_yes = srWGS_all_yes * EHR_menopauseCode_all_yes,
    intersect2_srWGS_Survey_menopauseQuestion_all_yes = srWGS_all_yes * Survey_menopauseQuestion_all_yes,
    intersect2_EHR_menopauseCode_Survey_menopauseQuestion_all_yes = EHR_menopauseCode_all_yes * Survey_menopauseQuestion_all_yes,
    intersect3_srWGS_EHR_menopauseCode_Survey_menopauseQuestion_all_yes = srWGS_all_yes * EHR_menopauseCode_all_yes * Survey_menopauseQuestion_all_yes
  ) %>%
  # calculate ages for every datetime column by subtracting the date of birth
  mutate(
    age_from_birth_date_current_year = calculate_age(
      event_date = today(),
      birth_date = date_of_birth
    ),
    age_at_demographic_survey = calculate_age(
      event_date = demographic_survey_datetime,
      birth_date = date_of_birth
    ),
    age_at_date_Education = calculate_age(
      event_date = date_Education,
      birth_date = date_of_birth
    ),
    age_at_date_Income = calculate_age(
      event_date = date_Income,
      birth_date = date_of_birth
    )
  ) %>%
  # calculate ages for every EHR and survey datetime column by subtracting the date of birth
  mutate(
    across(
      .cols = names(.)[startsWith(names(.), "date_conditionEHR_")],
      .fns = ~ calculate_age(
        event_date = .x,
        birth_date = date_of_birth
      ),
      .names = "age_at_{.col}"
    ),
    across(
      .cols = names(.)[startsWith(names(.), "date_surveyQ_")],
      .fns = ~ calculate_age( 
        event_date = .x,
        birth_date = date_of_birth
      ),
      .names = "age_at_{.col}"
    )
  ) %>%
  # make sure all age columns are numeric vectors
  mutate(
    across(
      .cols = names(.)[grepl("age", names(.))],
      .fns = ~ as.numeric(.x)
    )
  ) %>%
  # Create age quartile and menopause transition group columns
  mutate(
    across(
      .cols = names(.)[grepl("age", names(.))],
      .fns = list(
        # Age quartile: Q1 = 19–41, Q2 = 42–57, Q3 = 58–69, Q4 = 70+
        Q = ~ case_when(
          .x >= 19 & .x <= 41 ~ "Q1",
          .x >= 42 & .x <= 57 ~ "Q2",
          .x >= 58 & .x <= 69 ~ "Q3",
          .x >= 70            ~ "Q4",
          TRUE ~ NA_character_
        ),
        # Menopause Transition Age groups: MTA1 = <40, MTA2 = 40–60, MTA3 = >60
        MTA = ~ case_when(
          .x < 40             ~ "MTA1",
          .x >= 40 & .x <= 60 ~ "MTA2",
          .x > 60             ~ "MTA3",
          TRUE ~ NA_character_
        )
      ),
      .names = "{.col}_{.fn}"
    )
  )

# check that all person_IDs are unique
Demographic_data_all_AoURP$person_id %>% unique(x = .) %>% length(x = .)
Demographic_data_all_AoURP %>%
  nrow(x = .)

# preview dataset
Demographic_data_all_AoURP %>%
  head(x = .)

# output column names
Demographic_data_all_AoURP %>%
  names(x = .)

# filter dataset to female sex only
Demographic_data_all_AoURP <-
  Demographic_data_all_AoURP %>%
  filter(
    .data = .,
    sex_at_birth=="Female"
  ) %>%
  # clean up skip and NA answers for demographic strata
  mutate(
    .data = .,
    Education = if_else(
      condition = (Education=="PMI: Prefer Not To Answer") | 
        (Education=="PMI: Skip"),
      true = "PNA Skip",
      false = Education
    ),
    ethnicity = if_else(
      condition = (ethnicity=="No matching concept") | 
        (ethnicity=="What Race Ethnicity: Race Ethnicity None Of These") | 
        (ethnicity=='PMI: Prefer Not To Answer') |
        (ethnicity=='PMI: Skip'),
      true = "PNA Skip",
      false = ethnicity
    ),
    Income = if_else(
      condition = (Income=='PMI: Prefer Not To Answer') |
        (Income=='PMI: Skip'),
      true = "PNA Skip",
      false = Income
    ),
    race = if_else(
      condition = (race=='None Indicated') |
        (race=='None of these') |
        (race=='I prefer not to answer') |
        (race=='PMI: Skip'),
      true = "PNA Skip",
      false = race
    )
    
  )

# enrollment data (to get enrollment dates/ages)
# You can find what participants have given consent to their EHR by querying the observation table for 
# participants who have observation_source_concept_id = 1586099 (EHRConsentPII_ConsentPermission) with 
# value_source_concept_id = 1586100 (Yes).

library(bigrquery)
library(tidyverse)

CDR_DATASET= Sys.getenv('WORKSPACE_CDR')

# helper function

download_data <- function(query) {
  
  tb <- bq_project_query(Sys.getenv('GOOGLE_PROJECT'), query)
  
  bq_table_download(tb)
  
}



query = str_glue("

               SELECT *

               FROM `{CDR_DATASET}.observation`

               WHERE observation_concept_id = 1586099

               AND value_source_concept_id = 1586100 #ConsentPermission_Yes"
                 
)

ehr_consented_pids_df = download_data(query)

head(ehr_consented_pids_df)

ehr_consented_pids_df <-
  ehr_consented_pids_df %>%
  # select person id and EHR consent date time columns
  select(
    .data = .,
    person_id,
    "EHRconsent_datetime" = observation_datetime,
  ) %>%
  # create an EHR consent column
  mutate(
    .data = .,
    EHR_consent = "yes"
  ) %>%
  # filter to earliest consent time per person
  group_by(
    .data = .,
    person_id
  ) %>%
  slice_min(EHRconsent_datetime, with_ties = FALSE) %>%
  ungroup()

# # save the EHR consent table to the file system as a frozen dataset
# ehr_consented_pids_df %>%
# write_tsv(
#     x = .,
#     file = "./MenoSummaryStats_CUWHC_poster_VERSION8/ehr_consented_pids_df_V8_freeze09182025.tsv"
#     )

# read in the frozen EHR consent table
ehr_consented_pids_df <-
  read.delim(
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/ehr_consented_pids_df_V8_freeze09182025.tsv",
    header = TRUE
  )

nrow(ehr_consented_pids_df)
ehr_consented_pids_df$person_id %>% length(x = .)
ehr_consented_pids_df$person_id %>% unique(x = .) %>% length(x = .)

Demographic_data_all_AoURP <- 
  # add the EHR consent information to the demographic data table
  list(
    Demographic_data_all_AoURP,
    ehr_consented_pids_df
  ) %>%
  # join all tables by person ID
  reduce(
    .x = .,
    .f = full_join,
    by = "person_id"
  ) %>%
  # replace NA in the EHR consent column with "no"
  mutate(
    .data = .,
    EHR_consent = if_else(
      condition = is.na(x = EHR_consent),
      true = "no",
      false = EHR_consent
    )
  ) %>%
  # calculate age at consent with birth date and consent date time
  mutate(
    .data = .,
    EHRconsent_age = calculate_age(
      event_date = EHRconsent_datetime,
      birth_date = date_of_birth
    )
  ) %>%
  # replace NA values in EHR all and survey all columns with 0's because they are one-hot encoded columns
  # replace missing NA values with 0 for one-hot encoded columns that were joined
  mutate(
    .data = .,
    across(
      .cols = all_of(
        
        x = c(
          # more general total one-hot encoded AOURP columns
          "srWGS_all_yes",
          "EHR_all_yes",
          "survey_all_yes",
          "EHR_menopauseCode_all_yes",
          "Survey_menopauseQuestion_all_yes"
        )
      ), 
      .fns = ~ replace_na(.x, 0)
    )
  ) 

# # save the file of all menopause EHR, survey, sr-WGS, and sociodemographic data to the file system
# Demographic_data_all_AoURP %>%
# write_tsv(
#     x = .,
#     file = "./MenoSummaryStats_CUWHC_poster_VERSION8/MenopauseMasterEHRsurveyWGSsociodemographicsFile_V8_freeze09182025.tsv"
#     )

library(tidyverse)

# load the demographic data freeze that was created
Demographic_data_all_AoURP <-
  read.delim(
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/MenopauseMasterEHRsurveyWGSsociodemographicsFile_V8_freeze09182025.tsv",
    header = TRUE
  )

# obtain individuals with female sex with the self-reported survey hysterectomy age and ovary removal age data
person_id_femaleSex <- 
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    person_id,
    sex_at_birth
  ) %>%
  filter(
    .data = .,
    sex_at_birth=="Female"
  ) %>%
  pull(
    .data = .,
    person_id
  )

print("female sex self-reported hysterectomy age summary stats")
# self-reported hysterectomy age summary stats
HysterectomyAgeData %>% 
  filter(
    .data = .,
    person_id %in% person_id_femaleSex
  ) %>%
  summarize(
    .data = .,
    "N" = n(),
    "Q1" = quantile(x = HysterectomyAge,probs = 0.25),
    "Median" = median(x = HysterectomyAge),
    "Q3" = quantile(x = HysterectomyAge,probs = 0.75),
    "IQR" = IQR(x = HysterectomyAge)
  )

print("female sex self-reported ovary removal age summary stats")
# self-reported survey ovary removal age summary stats
OvaryRemoveAgeData %>%
  filter(
    .data = .,
    person_id %in% person_id_femaleSex
  ) %>%
  summarize(
    .data = .,
    "N" = n(),
    "Q1" = quantile(x = OvaryRemoveAge,probs = 0.25),
    "Median" = median(x = OvaryRemoveAge),
    "Q3" = quantile(x = OvaryRemoveAge,probs = 0.75),
    "IQR" = IQR(x = OvaryRemoveAge)
  )

# print column names to screen
Demographic_data_all_AoURP %>% names()

# identify the sample size that actually reported health insurance type for females
N_reportedInsuranceType <-
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    sex_at_birth,
    Health_Insurance,
    Health_Insurance_Type
  ) %>%
  # filter to female
  filter(
    .data = .,
    sex_at_birth=="Female"
  ) %>%
  # obtain insurance type sample size
  select(.data = .,Health_Insurance_Type) %>%
  group_by(.data = .,Health_Insurance_Type) %>%
  summarize(
    .data = .,
    "N" = n() 
  ) %>%
  ungroup(x = .) %>%
  # remove skip and prefer not answer
  filter(.data = .,Health_Insurance_Type!="Skip") %>%
  filter(.data = .,Health_Insurance_Type!="Prefer Not To Answer") %>%
  # sum those that reported insurance type
  mutate(
    .data = .,
    Total_N = sum(x = N,na.rm = TRUE)
  ) %>%
  pull(.data = .,Total_N) %>%
  unique(x = .)

# identify sample size no reported insurance type
N_NO_reportedInsuranceType <-
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    sex_at_birth,
    Health_Insurance,
    Health_Insurance_Type
  ) %>%
  # filter to female
  filter(
    .data = .,
    sex_at_birth=="Female"
  ) %>%
  # obtain insurance type sample size
  select(.data = .,Health_Insurance_Type) %>%
  group_by(.data = .,Health_Insurance_Type) %>%
  summarize(
    .data = .,
    "N" = n() 
  ) %>%
  ungroup(x = .) %>%
  # keep skip and prefer not answer
  filter(
    .data = .,
    (Health_Insurance_Type=="Skip") | 
      (Health_Insurance_Type=="Prefer Not To Answer")
  ) %>%
  # sum those that did not report insurance type
  mutate(
    .data = .,
    Total_N = sum(x = N,na.rm = TRUE)
  ) %>%
  pull(.data = .,Total_N) %>%
  unique(x = .)

print("N_reportedInsuranceType")
print(N_reportedInsuranceType)

print("N_reportedInsuranceType rounded up to nearest 5")
ceiling(x = N_reportedInsuranceType/5)*5

print("N_NO_reportedInsuranceType")
print(N_NO_reportedInsuranceType)

print("N_NO_reportedInsuranceType rounded up to nearest 5")
ceiling(x = N_NO_reportedInsuranceType/5)*5

print("percent that reported insurance type of total")
round(x = (N_reportedInsuranceType/(N_reportedInsuranceType+N_NO_reportedInsuranceType))*100,digits = 2)


N_ageOver70_noMenopause <-
  # calculate number of females age > 70 that said no to survey menopause or did not report yes to menopause
  Demographic_data_all_AoURP %>%
  filter(
    .data = .,
    # not yes answers to menopause question
    (
      (surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Periods_Havent_Stopped==1) |
        (surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Not_Sure_Menstrual_Stopped==1) |
        (surveyQ_Overall_Health_Menstrual_Stopped_PMI_Prefer_Not_To_Answer==1) |
        (surveyQ_Overall_Health_Menstrual_Stopped_PMI_Skip==1)
    ) &
      # age > 70 for not yes menopause answers
      (
        (age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Periods_Havent_Stopped > 70) |
          (age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Not_Sure_Menstrual_Stopped > 70) |
          (age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_PMI_Prefer_Not_To_Answer > 70) |
          (age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_PMI_Skip > 70)
      ) &
      # and make sure that at least one of the ages is NOT NA
      (
        !is.na(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Periods_Havent_Stopped) |
          !is.na(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Not_Sure_Menstrual_Stopped) | 
          !is.na(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_PMI_Prefer_Not_To_Answer) |
          !is.na(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_PMI_Skip)
      )
  ) %>%
  nrow()

N_ageOver70_answeredMenopauseQuestion <-
  # calculate total females with age > 70 that answered the menopause question (any answer)
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    contains(match = "Overall_Health_Menstrual_Stopped")
  ) %>%
  filter(
    .data = .,
    # answered any menopause survey question
    (
      (surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Periods_Havent_Stopped==1) |
        (surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None==1) |
        (surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Not_Sure_Menstrual_Stopped==1) |
        (surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone==1) |
        (surveyQ_Overall_Health_Menstrual_Stopped_PMI_Prefer_Not_To_Answer==1) |
        (surveyQ_Overall_Health_Menstrual_Stopped_PMI_Skip==1) 
    ) &
      # age > 70
      (
        (age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Periods_Havent_Stopped > 70) |
          (age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None > 70) |
          (age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Not_Sure_Menstrual_Stopped > 70) |
          (age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone > 70) |
          (age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_PMI_Prefer_Not_To_Answer > 70) |
          (age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_PMI_Skip > 70)
      ) &
      # age is NOT missing (NA)
      (
        !is.na(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None) |
          !is.na(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone) |
          !is.na(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Periods_Havent_Stopped) |
          !is.na(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Not_Sure_Menstrual_Stopped) | 
          !is.na(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_PMI_Prefer_Not_To_Answer) |
          !is.na(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_PMI_Skip)
      )
  ) %>%
  nrow()

N_ageOver70_noMenopause
N_ageOver70_answeredMenopauseQuestion
(N_ageOver70_noMenopause/N_ageOver70_answeredMenopauseQuestion)*100

N_menopauseSurvey_YesNone_or_Hormone <-
  # number of unique females with yes none or yes hormone response to menopause survey
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    person_id,
    surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None,
    surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone
  ) %>%
  filter(
    .data = .,
    (surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None==1) |
      (surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone==1)
  ) %>%
  nrow()

N_menopauseSurvey_YesNone_or_Hormone

# number of unique females with menopause present or premature menopause code
N_menopauseEHR_present_or_premature <-
  # number of unique females with yes none or yes hormone response to menopause survey
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    person_id,
    conditionEHR_Menopause_present_289903006_SNOMED,
    conditionEHR_Premature_menopause_373717006_SNOMED
  ) %>%
  filter(
    .data = .,
    (conditionEHR_Menopause_present_289903006_SNOMED==1) |
      (conditionEHR_Premature_menopause_373717006_SNOMED==1)
  ) %>%
  nrow()

N_menopauseEHR_present_or_premature

# number with yes menopause EHR, survey, and genomic data
Demographic_data_all_AoURP$intersect3_srWGS_EHR_menopauseCode_Survey_menopauseQuestion_all_yes %>%
  sum(na.rm = TRUE)

# ancestry sample sizes (female sex)
# count N with genomic data
ceiling(x = sum(Demographic_data_all_AoURP$srWGS_all_yes)/5)*5
# count N with no genomic data
ceiling(x = sum(x = as.numeric(x = Demographic_data_all_AoURP$srWGS_all_yes==0))/ 5)*5

# count ancestries for females with genomic data
Demographic_data_all_AoURP$ancestry_pred %>%
  table() %>%
  data.frame() %>%
  # round N up to nearest 5
  mutate(
    .data = .,
    Freq_round_5 = ceiling(x = Freq/5)*5
  ) %>%
  mutate(.data = .,total = sum(Freq)) 

### age summary statistics of hysterectomy, ovary removal and reason for menstrual stop = surgery
# and answered "yes none" to menstrual stopped question

print("hysterectomy = yes ages")
# hysterectomy
Demographic_data_all_AoURP %>%
  select(
    .data = .,
    surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes,
    age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes
  ) %>%
  filter(
    .data = .,
    surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes==as.integer(x = 1)
  ) %>% 
  summarize(
    .data = .,
    "median" = median(x = age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes,na.rm = TRUE),
    "Q1" = quantile(age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes, 0.25, na.rm = TRUE),
    "Q3" = quantile(age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes, 0.75, na.rm = TRUE)
  )

# hysterectomy
Demographic_data_all_AoURP %>%
  select(
    .data = .,
    surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes,
    age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes_MTA
  ) %>%
  filter(
    .data = .,
    surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes==as.integer(x = 1)
  ) %>%
  group_by(
    .data = .,
    age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes_MTA
  ) %>%
  summarize(
    .data = .,
    sample_size = n()
  ) %>%
  ungroup(x = .) %>%
  mutate(
    .data = .,
    percent = signif((sample_size/sum(sample_size))*100,2)
  )

print("ovary removal")
# ovary removal
Demographic_data_all_AoURP %>%
  select(
    .data = .,
    surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Both,
    surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Sectioned,
    surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Unsure,
    age_at_date_surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Both,
    age_at_date_surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Sectioned,
    age_at_date_surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Unsure
  ) %>%
  filter(
    .data = .,
    (surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Both==1) |
      (surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Sectioned==1) |
      (surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Unsure==1)
  ) %>%
  mutate(
    .data = .,
    # obtain non-missing age
    age = coalesce(
      age_at_date_surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Both,
      age_at_date_surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Sectioned,
      age_at_date_surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Unsure
    )
  ) %>%
  summarize(
    .data = .,
    "median" = median(x = age,na.rm = TRUE),
    "Q1" = quantile(age, 0.25, na.rm = TRUE),
    "Q3" = quantile(age, 0.75, na.rm = TRUE)
  )

# reason for menstrual stop = survey
Demographic_data_all_AoURP %>%
  select(
    .data = .,
    surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery,
    age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery
  ) %>%
  filter(
    .data = .,
    surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery==as.integer(x = 1)
  ) %>%
  summarize(
    .data = .,
    "median" = median(x = age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery,na.rm = TRUE),
    "Q1" = quantile(age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery, 0.25, na.rm = TRUE),
    "Q3" = quantile(age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery, 0.75, na.rm = TRUE)
  )

# ages and sample sizes for individuals that said no to hysterectomy question
Demographic_data_all_AoURP %>%
  select(
    .data = .,
    surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No,
    age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No_MTA
  ) %>%
  filter(
    .data = .,
    surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No==as.integer(x = 1)
  ) %>%
  group_by(
    .data = .,
    age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No_MTA
  ) %>%
  summarize(
    .data = .,
    sample_size = n()
  ) %>%
  ungroup(x = .) %>%
  mutate(
    .data = .,
    percent = signif((sample_size/sum(sample_size))*100,2)
  )

print("age summary answered yes none to menstrual stopped")
# age summary answered yes none to menstrual stopped
Demographic_data_all_AoURP %>%
  select(
    .data = .,
    surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None
  ) %>%
  filter(
    .data = .,
    surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None==as.integer(x = 1)
  ) %>%
  summarize(
    .data = .,
    "median" = median(x = age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None,na.rm = TRUE),
    "Q1" = quantile(age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None, 0.25, na.rm = TRUE),
    "Q3" = quantile(age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None, 0.75, na.rm = TRUE)
  )

Demographic_data_all_AoURP %>%
  select(
    .data = .,
    surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_MTA
  ) %>%
  filter(
    .data = .,
    surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None==as.integer(x = 1)
  ) %>%
  group_by(
    .data = .,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_MTA
  ) %>%
  summarize(
    .data = .,
    sample_size = n()
  ) %>%
  ungroup(x = .) %>%
  mutate(
    .data = .,
    percent = signif((sample_size/sum(sample_size))*100,2)
  )

EHR_menopause_code_repeats_table <- 
  # summary/count of how many repeat EHR occurrences there usually were per woman
  Granular_Menopause_EHR_condition_data %>%
  # select useful columns
  select(
    .data = .,
    person_id,
    standard_concept_name:condition_start_datetime
  ) %>%
  # filter to the person IDs in the Demographic_data_all_AoURP (sex = Female only)
  filter(
    .data = .,
    person_id %in% Demographic_data_all_AoURP$person_id
  ) %>%
  # combine concept and vocabulary columns into condition identifier
  mutate(
    .data = .,
    condition_EHR = paste(standard_concept_name,standard_concept_code,standard_vocabulary) %>%
      gsub(pattern = " ",replacement = "_",x = .)
  ) %>%
  # filter to the menopause present condition
  filter(
    .data = .,
    condition_EHR=="Menopause_present_289903006_SNOMED"
  ) %>%
  # group by person
  group_by(
    .data = .,
    person_id
  ) %>%
  # count repeats of code per person
  summarize(
    .data = .,
    "N_perPerson" = n()
  ) %>%
  # ungroup
  ungroup() %>%
  # remove person ID
  select(
    .data = .,
    -person_id
  ) %>%
  # group by the number of repeats for each person
  group_by(
    .data = .,
    N_perPerson
  ) %>%
  # count the number of the number of repeats for each person
  summarize(
    .data = .,
    "Number_of_each_repeat" = n()
  ) 
#         %>%
#         # if the Number_of_each_repeat is < 20, round to 20
#         # if the Number_of_each_repeat is >=20, round up to nearest 5
#           mutate(
#              .data = .,
#              Number_of_each_repeat = case_when(
#                                       Number_of_each_repeat < 20 ~ 20,
#                                       TRUE ~ ceiling(Number_of_each_repeat / 5) * 5
#                                     )
#             )

# number of individuals with 1 occurance of code
EHR_menopause_code_repeats_table %>%
  filter(
    .data = .,
    N_perPerson == 1
  )

# number of individuals with > 1 occurance of code
EHR_menopause_code_repeats_table %>%
  filter(
    .data = .,
    N_perPerson > 1
  ) %>%
  unique() %>%
  pull(
    .data = .,
    Number_of_each_repeat
  ) %>%
  sum(
    x = .,
    na.rm = TRUE
  ) %>%
  paste0("Number of individuals with > 1 occurance of code: ",.)

# number of individuals with 2, 3, 4, and 5 codes
EHR_menopause_code_repeats_table %>%
  filter(
    .data = .,
    N_perPerson %in% c(2,3,4,5)
  )

# number of individuals with > 5 occurance of code
EHR_menopause_code_repeats_table %>%
  filter(
    .data = .,
    N_perPerson > 5
  ) %>%
  unique() %>%
  pull(
    .data = .,
    Number_of_each_repeat
  ) %>%
  sum(
    x = .,
    na.rm = TRUE
  ) %>%
  paste0("Number of individuals with > 5 occurance of code: ",.)

EHR_menopause_code_repeats_table %>%
  write_tsv(
    x = .,
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/EHR_menopause_code_repeats_table.tsv"
  )

EHR_menopause_code_repeats_table

# create a dataset to compute intersected sample sizes of granular menopause survey and EHR variables
MenopauseIntersectionSampleSizeDataset <- 
  Granular_Menopause_Survey_Response_clean_final_oneHot %>% 
  # join with the EHR data
  left_join(
    x = .,
    y = Granular_Menopause_EHR_condition_data_clean_final_oneHot,
    by = c("person_id")
  ) %>%
  # replace missing NA values with 0 for one-hot encoded columns that were joined
  mutate(
    .data = .,
    across(
      .cols = all_of(
        
        x = c(
          # starting with "conditionEHR_"
          names(.)[startsWith(names(.), "conditionEHR_")]
        )
      ), 
      .fns = ~ replace_na(.x, 0)
    )
  ) %>%
  # join with the demographic data that has menopause transition ages computed for
  # individuals with female sex
  left_join(
    x = .,
    # select the person IDs from the Demographic_data_all_AoURP (all female sex)
    y = Demographic_data_all_AoURP %>%
      select(
        .data = .,
        person_id,
        sex_at_birth,
        matches("^age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_.*_MTA$")
      ) ,
    by = c("person_id")
  ) %>%
  # filter to female sex only
  filter(
    .data = .,
    sex_at_birth=="Female"
  ) %>%
  # drop the sex column
  select(
    .data = .,
    -sex_at_birth
  )

MenopauseIntersectionSampleSizeDataset %>%
  head()

MenopauseIntersectionSampleSizeDataset %>%
  nrow()

MenopauseIntersectionSampleSizeDataset %>%
  select(starts_with(match = "conditionEHR_")) %>%
  names()

# compute sample sizes of combinations of menopause descriptors 
# with age of menopause transition included (without demographic data)
Menopause_sample_size_combinations_with_menopause_transition_age <-
  MenopauseIntersectionSampleSizeDataset %>%
  select(
    starts_with("surveyQ_Overall_Health_Menstrual_Stopped_"),
    starts_with("surveyQ_Yes_None_Menstrual_Stopped_Reason_"),
    starts_with("surveyQ_Overall_Health_Hysterectomy_History_"),
    starts_with("surveyQ_Overall_Health_Ovary_Removal_History_"),
    starts_with("conditionEHR_"),
    matches("^age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_.*_MTA$")
  ) %>%
  # select the non-missing menopause transition age for the menstrual stopped question
  mutate(
    age_menopause_transition = coalesce(!!!select(., matches("^age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_.*_MTA$")))
  ) %>% 
  select(
    .data = .,
    # drop the MTA columns no longer needed
    -matches("^age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_.*_MTA$"),
    # drop the resistant ovary syndrome diagnosis also
    -conditionEHR_Resistant_ovary_syndrome_80956002_SNOMED
  ) %>%
  # compute sample sizes of all combinations of the table variables
  count(across(everything())) 


# compute sample sizes of combinations of menopause descriptors 
# with NO menopause transition age or demographic data included
Menopause_sample_size_combinations_NO_AGE <-
  MenopauseIntersectionSampleSizeDataset %>%
  select(
    starts_with("surveyQ_Overall_Health_Menstrual_Stopped_"),
    starts_with("surveyQ_Yes_None_Menstrual_Stopped_Reason_"),
    starts_with("surveyQ_Overall_Health_Hysterectomy_History_"),
    starts_with("surveyQ_Overall_Health_Ovary_Removal_History_"),
    starts_with("conditionEHR_")
  ) %>%
  select(
    .data = .,
    # drop the resistant ovary syndrome diagnosis
    -conditionEHR_Resistant_ovary_syndrome_80956002_SNOMED
  ) %>%
  # compute sample sizes of all combinations of the table variables
  count(across(everything())) %>%
  # create an age_menopause_transition with as placeholder since not included
  mutate(
    .data = .,
    age_menopause_transition = "not included"
  ) 

IntersectSampleSize_menopause_EHR_survey_combinations <- 
  # bind the two tables of sample size combinations together by row
  list(
    Menopause_sample_size_combinations_with_menopause_transition_age,
    Menopause_sample_size_combinations_NO_AGE
  ) %>%
  do.call(
    what = "rbind",
    args = .
  ) %>%
  # sort descending
  arrange(
    .data = .,
    desc(x = n)
  ) %>%
  # filter out the NA age_menopause_transition numbers since the age_menopause_transition=="not included"
  # is the same result
  filter(
    .data = .,
    !is.na(x = age_menopause_transition)
  ) %>%
  # filter out the not included also since we are more interested within the age groups
  filter(
    .data = .,
    age_menopause_transition!="not included"
  ) %>%
  # protect against N<20
  mutate(
    .data = .,
    n = if_else(
      condition = n <= 20,
      true = as.character(x = "N≤20"),
      false = as.character(x = n)
    )
  ) %>%
  # clean up column values
  mutate(
    .data = .,
    age_menopause_transition = age_menopause_transition %>%
      sub(pattern = "MTA1",replacement = "pre (age < 40)",x = .) %>%
      sub(pattern = "MTA2",replacement = "peri (age 40-60)",x = .) %>%
      sub(pattern = "MTA3",replacement = "post (age > 60)",x = .)#,
    #             surveyQ_Overall_Health_Menstrual_Stopped = surveyQ_Overall_Health_Menstrual_Stopped %>%
    #                                                        sub(
    #                                                            pattern = "Menstrual Stopped",
    #                                                            replacement = "",
    #                                                            x = .
    #                                                            ) %>%
    #                                                         sub(
    #                                                             pattern =  " Menstrual Stopped",
    #                                                             replacement = "",
    #                                                             x = .
    #                                                             ),
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason = surveyQ_Yes_None_Menstrual_Stopped_Reason %>%
    #                                                         sub(
    #                                                            pattern = "Menstrual Stopped Reason ",
    #                                                            replacement = "",
    #                                                            x = .
    #                                                            ),
    #             surveyQ_Overall_Health_Hysterectomy_History = surveyQ_Overall_Health_Hysterectomy_History %>%
    #                                                           sub(
    #                                                            pattern = "Hysterectomy History ",
    #                                                            replacement = "",
    #                                                            x = .
    #                                                            ),
    #             surveyQ_Overall_Health_Ovary_Removal_History = surveyQ_Overall_Health_Ovary_Removal_History %>%
    #                                                            sub(
    #                                                              pattern = "Ovary Removal History ",
    #                                                              replacement = "",
    #                                                              x = .
    #                                                              )
    
  ) %>% 
  # reorder and rename columns
  select(
    .data = .,
    "N" = n,
    "age (menopause transition)" = age_menopause_transition,
    everything()
    #             "menstrual stopped" = surveyQ_Overall_Health_Menstrual_Stopped,
    #             "menstrual stopped reason" = surveyQ_Yes_None_Menstrual_Stopped_Reason,
    #             "hysterectomy history" = surveyQ_Overall_Health_Hysterectomy_History,
    #             "ovary removal history" = surveyQ_Overall_Health_Ovary_Removal_History,
    #             "menopause present (289903006)" = conditionEHR_Menopause_present_289903006_SNOMED,
    #             "premature menopause (373717006)" = conditionEHR_Premature_menopause_373717006_SNOMED,
    #             "primary ovarian failure (65846009)" = conditionEHR_Primary_ovarian_failure_65846009_SNOMED,
    #             "premature ovarian failure (237788002)" = conditionEHR_Premature_ovarian_failure_237788002_SNOMED,
    #             "menopause ovarian failure (237138004)" = conditionEHR_Menopause_ovarian_failure_237138004_SNOMED,
    #             "abnormal vasomotor function (70670009)" = conditionEHR_Abnormal_vasomotor_function_70670009_SNOMED
  )

# # view the table 
# IntersectSampleSize_menopause_EHR_survey_combinations %>%
# head(x = .)

# # count rows
# IntersectSampleSize_menopause_EHR_survey_combinations %>% 
# unique() %>%
# nrow()

IntersectSampleSize_menopause_EHR_survey_combinations %>%
  # save the result to the file system
  write_tsv(
    x = .,
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/IntersectSampleSize_menopause_EHR_survey_combinations.tsv"
  )

# create table 3 for the manuscript (age > 60, 10 most frequent combinations)
IntersectSampleSize_menopause_EHR_survey_combinations %>%
  filter(
    .data = .,
    `age (menopause transition)`== "post (age > 60)"
  ) %>%
  head(10) %>%
  # save the result to the file system
  write_tsv(
    x = .,
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Table3_age_above60_menopause_EHR_survey_combinations.tsv"
  )


IntersectSampleSize_menopause_EHR_survey_combinations %>%
  filter(
    .data = .,
    `age (menopause transition)`== "post (age > 60)" &
      surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause==1 &
      IntersectSampleSize_menopause_EHR_survey_combinations$surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No==1 &
      IntersectSampleSize_menopause_EHR_survey_combinations$surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_No==1
  ) %>%
  head(1)

IntersectSampleSize_menopause_EHR_survey_combinations %>%
  filter(
    .data = .,
    `age (menopause transition)`== "peri (age 40-60)" &
      surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause==1 &
      IntersectSampleSize_menopause_EHR_survey_combinations$surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No==1 &
      IntersectSampleSize_menopause_EHR_survey_combinations$surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_No==1
  ) %>%
  head(1)

IntersectSampleSize_menopause_EHR_survey_combinations %>%
  filter(
    .data = .,
    `age (menopause transition)`== "pre (age < 40)" &
      surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause==1 &
      IntersectSampleSize_menopause_EHR_survey_combinations$surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No==1 &
      IntersectSampleSize_menopause_EHR_survey_combinations$surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_No==1
  ) %>%
  head(1)

N_ageOver60_menopauseSurgery_hysterectomy_ovaryRemoval <-
  # identify the number of females age > 60 with survey response of
  # yes to surgical menopause and ovary removal and histerectomy
  IntersectSampleSize_menopause_EHR_survey_combinations %>%
  filter(
    .data = .,
    # menstrual stop reason surgery
    (surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery==1) &
      # yes to hysterectomy
      (surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes==1) &
      # yes to ovary removal
      (
        (surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Both==1) |
          (surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Sectioned==1) |
          (surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Unsure==1) 
      ) &
      (`age (menopause transition)`== "post (age > 60)")
  ) %>%
  # round to nearest 5
  mutate(
    .data = .,
    N_rounded = ceiling(as.numeric(N) / 5) * 5
  ) %>%
  # replace NA with 20
  mutate(
    .data = .,
    N_rounded = if_else(
      condition = is.na(x = N_rounded),
      true = 20,
      false = N_rounded
    )
  ) %>%
  # sum the rounded N
  mutate(
    .data = .,
    Sum_rounded = N_rounded %>% sum(x = .,na.rm = TRUE)
  ) %>%
  unique(x = .) %>%
  select(
    .data = .,
    N,
    N_rounded,
    Sum_rounded,
    `age (menopause transition)`,
    surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery,
    surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes,
    surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Both,
    surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Sectioned,
    surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Unsure,
    conditionEHR_Menopause_present_289903006_SNOMED,
    conditionEHR_Premature_menopause_373717006_SNOMED
  ) %>%
  pull(.data = .,Sum_rounded) %>%
  unique(x = .)

N_ageOver60_menopauseSurgery_hysterectomy_ovaryRemoval_withEHRmenopause <-
  # identify the number of females age > 60 with survey response of
  # yes to surgical menopause and ovary removal and histerectomy AND
  # EHR menopause present 
  IntersectSampleSize_menopause_EHR_survey_combinations %>%
  filter(
    .data = .,
    # menstrual stop reason surgery
    (surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery==1) &
      # yes to hysterectomy
      (surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes==1) &
      # yes to ovary removal
      (
        (surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Both==1) |
          (surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Sectioned==1) |
          (surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Unsure==1) 
      ) &
      # age > 60
      (`age (menopause transition)`== "post (age > 60)") &
      # EHR menopause present 
      (
        (conditionEHR_Menopause_present_289903006_SNOMED==1) #|
        #(conditionEHR_Premature_menopause_373717006_SNOMED==1)
      )
  ) %>%
  # round to nearest 5
  mutate(
    .data = .,
    N_rounded = ceiling(as.numeric(N) / 5) * 5
  ) %>%
  # replace NA with 20
  mutate(
    .data = .,
    N_rounded = if_else(
      condition = is.na(x = N_rounded),
      true = 20,
      false = N_rounded
    )
  ) %>%
  # sum the rounded N
  mutate(
    .data = .,
    Sum_rounded = N_rounded %>% sum(x = .,na.rm = TRUE)
  ) %>%
  unique(x = .) %>%
  select(
    .data = .,
    N,
    N_rounded,
    Sum_rounded,
    `age (menopause transition)`,
    surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery,
    surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes,
    surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Both,
    surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Sectioned,
    surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Unsure,
    conditionEHR_Menopause_present_289903006_SNOMED,
    conditionEHR_Premature_menopause_373717006_SNOMED
  ) %>%
  pull(.data = .,Sum_rounded) %>%
  unique(x = .)

N_ageOver60_menopauseSurgery_hysterectomy_ovaryRemoval
N_ageOver60_menopauseSurgery_hysterectomy_ovaryRemoval_withEHRmenopause
(N_ageOver60_menopauseSurgery_hysterectomy_ovaryRemoval_withEHRmenopause/N_ageOver60_menopauseSurgery_hysterectomy_ovaryRemoval)*100

# “natural menopause” without hysterectomy or ovary removal (answered "no") menopause transition age sample sizes
IntersectSampleSize_menopause_EHR_survey_combinations %>%
  filter(
    .data = .,
    # natural menopause
    (surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause==1) &
      # no to hysterectomy and ovary removal
      (surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No==1) &
      (surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_No==1)
  ) %>%
  # round to nearest 5
  mutate(
    .data = .,
    N_rounded = ceiling(as.numeric(N) / 5) * 5
  ) %>%
  # replace NA with 20
  mutate(
    .data = .,
    N_rounded = if_else(
      condition = is.na(x = N_rounded),
      true = 20,
      false = N_rounded
    )
  ) %>%
  # change NA to 20
  select(
    .data = .,
    N,
    N_rounded,
    `age (menopause transition)`,
    surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause,
    surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No,
    surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_No
  ) %>%
  group_by(
    .data = .,
    `age (menopause transition)`
  ) %>%
  summarize(
    .data = .,
    "sum_per_goup" = sum(N_rounded)
  ) %>%
  ungroup(x = .) %>%
  mutate(
    .data = .,
    Total_N = sum(sum_per_goup)
  ) %>%
  mutate(
    .data = .,
    Percent_of_total = (sum_per_goup/Total_N)*100
  )

Demographic_data_all_AoURP %>% names(x = .) %>% 
  grepl(pattern = "age",x = .) %>%
  which(x = .) %>% 
  names(x = Demographic_data_all_AoURP)[.]


### loop through the one-hot encoded variables and obtain sample sizes by categorical demographic characteristics
# and measures of central tendency for continuous variables (e.g., age)

# one-hot encoded variables
OneHot_Variables <- 
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    #         # EHR conditions: starts_with("conditionEHR_")
    #         conditionEHR_Abnormal_vasomotor_function_70670009_SNOMED,
    #         conditionEHR_Menopause_ovarian_failure_237138004_SNOMED,
    #         conditionEHR_Menopause_present_289903006_SNOMED,
    #         conditionEHR_Premature_menopause_373717006_SNOMED,
    #         conditionEHR_Premature_ovarian_failure_237788002_SNOMED,
    #         conditionEHR_Primary_ovarian_failure_65846009_SNOMED,
    #         # EHR condition ages
    #             # menopause present
    #              age_at_date_conditionEHR_Menopause_present_289903006_SNOMED,
    #              age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_Q,
    #              age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_MTA,
    #             # primary ovarian failure
    #             age_at_date_conditionEHR_Primary_ovarian_failure_65846009_SNOMED,
    #             age_at_date_conditionEHR_Primary_ovarian_failure_65846009_SNOMED_Q,
    #             age_at_date_conditionEHR_Primary_ovarian_failure_65846009_SNOMED_MTA,
    #             # premature menopause
    #             age_at_date_conditionEHR_Premature_menopause_373717006_SNOMED,
    #             age_at_date_conditionEHR_Premature_menopause_373717006_SNOMED_Q,
    #             age_at_date_conditionEHR_Premature_menopause_373717006_SNOMED_MTA,
    #             # abnormal vasomotor function
    #             age_at_date_conditionEHR_Abnormal_vasomotor_function_70670009_SNOMED,
    #             age_at_date_conditionEHR_Abnormal_vasomotor_function_70670009_SNOMED_Q,
    #             age_at_date_conditionEHR_Abnormal_vasomotor_function_70670009_SNOMED_MTA,
    #             # premature ovarian failure 
    #             age_at_date_conditionEHR_Premature_ovarian_failure_237788002_SNOMED,
    #             age_at_date_conditionEHR_Premature_ovarian_failure_237788002_SNOMED_Q,
    #             age_at_date_conditionEHR_Premature_ovarian_failure_237788002_SNOMED_MTA,
    #             # menopause ovarian failure
    #             age_at_date_conditionEHR_Menopause_ovarian_failure_237138004_SNOMED,
    #             age_at_date_conditionEHR_Menopause_ovarian_failure_237138004_SNOMED_Q,
    #             age_at_date_conditionEHR_Menopause_ovarian_failure_237138004_SNOMED_MTA,
    # all participants categories for data modality: contains("_all_yes")
    #         Demographic_AoURP_all_yes,
    Survey_menopauseQuestion_all_yes,
    #         EHR_menopauseCode_all_yes,
    #         srWGS_all_yes,
    #         intersect3_srWGS_EHR_menopauseCode_Survey_menopauseQuestion_all_yes,
    #         # data modality and demographic ages
    #             # demographic survey
    #              age_at_demographic_survey,
    #              age_at_demographic_survey_Q,
    #              age_at_demographic_survey_MTA,
    #             # education survey 
    #             age_at_date_Education,
    #             age_at_date_Education_Q,
    #             age_at_date_Education_MTA,
    #             # income survey
    #             age_at_date_Income,
    #             age_at_date_Income_Q,
    #             age_at_date_Income_MTA,
    # survey questions: starts_with("surveyQ_")
    # #             # hysterectomy
    #             surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No,
    #             surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Not_Sure,
    #             surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes,
    #             surveyQ_Overall_Health_Hysterectomy_History_No_matching_concept,
    #             surveyQ_Overall_Health_Hysterectomy_History_PMI_Prefer_Not_To_Answer,
    #             surveyQ_Overall_Health_Hysterectomy_History_PMI_Skip,
    #             # menstrual stop
    #            surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Not_Sure_Menstrual_Stopped,
    #            surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Periods_Havent_Stopped,
    surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone,
    surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None,
    #            surveyQ_Overall_Health_Menstrual_Stopped_PMI_Prefer_Not_To_Answer,
    #            surveyQ_Overall_Health_Menstrual_Stopped_PMI_Skip,
    # #             # ovary removal history
    #             surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_No,
    #             surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Not_Sure,
    #             surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Both,
    #             surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Sectioned,
    #             surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Unsure,
    #             surveyQ_Overall_Health_Ovary_Removal_History_PMI_Prefer_Not_To_Answer,
    #             surveyQ_Overall_Health_Ovary_Removal_History_PMI_Skip,
    # #             # menstrual stop reason
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Endometrial_Ablation,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Medication_Therapy,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_PMI_Not_Sure,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_PMI_Other,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_PMI_Prefer_Not_To_Answer,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_PMI_Skip,
    # survey ages
    #starts_with(match = "age_at_date_surveyQ")
    #         age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None,
    #         age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_Q,
    #         age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_MTA
  ) %>%
  names(x = .) %>%
  # sort alphabetically
  sort(x = .)

# sociodemographic variables
Sociodemographic_Variables <-
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    # continuous ages, age quartiles, and age menopause transition categories
    #starts_with(match = "age"),
    # EHR menopause present
    #             age_at_date_conditionEHR_Menopause_present_289903006_SNOMED,
    #             age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_Q,
    #             age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_MTA,
    # survey menstrual stop yes none
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_Q,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_MTA,
    # survery menstrual stop yes but hormone
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone_Q,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone_MTA,
    # survey menstrual stop reason = natural menopause
    #               age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause,
    #               age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause_Q,
    #               age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause_MTA,
    # survey hysterectomy
    #               age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes,
    #               age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes_Q,
    #               age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes_MTA,
    # demographics
    # demographic survey
    #              age_at_demographic_survey,
    #              age_at_demographic_survey_Q,
    #              age_at_demographic_survey_MTA,
    #              # education survey 
    #              age_at_date_Education,
    #              age_at_date_Education_Q,
    #              age_at_date_Education_MTA,
    #              # income survey
    #              age_at_date_Income,
    #              age_at_date_Income_Q,
    #              age_at_date_Income_MTA,
    # demographic information
    ancestry_pred,
    Education,
    ethnicity,
    Income,
    race
  ) %>%
  names()

OneHot_Variables
Sociodemographic_Variables

### loop through the one-hot encoded variables and obtain sample sizes by categorical demographic characteristics
# and measures of central tendency for continuous variables (e.g., age)

# one-hot encoded variables
OneHot_Variables <- 
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    #         # EHR conditions: starts_with("conditionEHR_")
    #         conditionEHR_Abnormal_vasomotor_function_70670009_SNOMED,
    #         conditionEHR_Menopause_ovarian_failure_237138004_SNOMED,
    #         conditionEHR_Menopause_present_289903006_SNOMED,
    #         conditionEHR_Premature_menopause_373717006_SNOMED,
    #         conditionEHR_Premature_ovarian_failure_237788002_SNOMED,
    #         conditionEHR_Primary_ovarian_failure_65846009_SNOMED,
    #         # EHR condition ages
    #             # menopause present
    #              age_at_date_conditionEHR_Menopause_present_289903006_SNOMED,
    #              age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_Q,
    #              age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_MTA,
    #             # primary ovarian failure
    #             age_at_date_conditionEHR_Primary_ovarian_failure_65846009_SNOMED,
    #             age_at_date_conditionEHR_Primary_ovarian_failure_65846009_SNOMED_Q,
    #             age_at_date_conditionEHR_Primary_ovarian_failure_65846009_SNOMED_MTA,
    #             # premature menopause
    #             age_at_date_conditionEHR_Premature_menopause_373717006_SNOMED,
    #             age_at_date_conditionEHR_Premature_menopause_373717006_SNOMED_Q,
    #             age_at_date_conditionEHR_Premature_menopause_373717006_SNOMED_MTA,
    #             # abnormal vasomotor function
    #             age_at_date_conditionEHR_Abnormal_vasomotor_function_70670009_SNOMED,
    #             age_at_date_conditionEHR_Abnormal_vasomotor_function_70670009_SNOMED_Q,
    #             age_at_date_conditionEHR_Abnormal_vasomotor_function_70670009_SNOMED_MTA,
    #             # premature ovarian failure 
    #             age_at_date_conditionEHR_Premature_ovarian_failure_237788002_SNOMED,
    #             age_at_date_conditionEHR_Premature_ovarian_failure_237788002_SNOMED_Q,
    #             age_at_date_conditionEHR_Premature_ovarian_failure_237788002_SNOMED_MTA,
    #             # menopause ovarian failure
    #             age_at_date_conditionEHR_Menopause_ovarian_failure_237138004_SNOMED,
    #             age_at_date_conditionEHR_Menopause_ovarian_failure_237138004_SNOMED_Q,
    #             age_at_date_conditionEHR_Menopause_ovarian_failure_237138004_SNOMED_MTA,
    # all participants categories for data modality: contains("_all_yes")
    #         Demographic_AoURP_all_yes,
    Survey_menopauseQuestion_all_yes,
    #         EHR_menopauseCode_all_yes,
    #         srWGS_all_yes,
    #         intersect3_srWGS_EHR_menopauseCode_Survey_menopauseQuestion_all_yes,
    #         # data modality and demographic ages
    #             # demographic survey
    #              age_at_demographic_survey,
    #              age_at_demographic_survey_Q,
    #              age_at_demographic_survey_MTA,
    #             # education survey 
    #             age_at_date_Education,
    #             age_at_date_Education_Q,
    #             age_at_date_Education_MTA,
    #             # income survey
    #             age_at_date_Income,
    #             age_at_date_Income_Q,
    #             age_at_date_Income_MTA,
    # survey questions: starts_with("surveyQ_")
    # #             # hysterectomy
    #             surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_No,
    #             surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Not_Sure,
    #             surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes,
    #             surveyQ_Overall_Health_Hysterectomy_History_No_matching_concept,
    #             surveyQ_Overall_Health_Hysterectomy_History_PMI_Prefer_Not_To_Answer,
    #             surveyQ_Overall_Health_Hysterectomy_History_PMI_Skip,
    #             # menstrual stop
    #            surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Not_Sure_Menstrual_Stopped,
    #            surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Periods_Havent_Stopped,
    surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone,
    surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None,
    #            surveyQ_Overall_Health_Menstrual_Stopped_PMI_Prefer_Not_To_Answer,
    #            surveyQ_Overall_Health_Menstrual_Stopped_PMI_Skip,
    # #             # ovary removal history
    #             surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_No,
    #             surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Not_Sure,
    #             surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Both,
    #             surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Sectioned,
    #             surveyQ_Overall_Health_Ovary_Removal_History_Ovary_Removal_History_Yes_Unsure,
    #             surveyQ_Overall_Health_Ovary_Removal_History_PMI_Prefer_Not_To_Answer,
    #             surveyQ_Overall_Health_Ovary_Removal_History_PMI_Skip,
    # #             # menstrual stop reason
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Endometrial_Ablation,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Medication_Therapy,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Surgery,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_PMI_Not_Sure,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_PMI_Other,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_PMI_Prefer_Not_To_Answer,
    #             surveyQ_Yes_None_Menstrual_Stopped_Reason_PMI_Skip,
    # survey ages
    #starts_with(match = "age_at_date_surveyQ")
    #         age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None,
    #         age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_Q,
    #         age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_MTA
  ) %>%
  names(x = .) %>%
  # sort alphabetically
  sort(x = .)

# sociodemographic variables
Sociodemographic_Variables <-
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    # continuous ages, age quartiles, and age menopause transition categories
    #starts_with(match = "age"),
    # EHR menopause present
    #             age_at_date_conditionEHR_Menopause_present_289903006_SNOMED,
    #             age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_Q,
    #             age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_MTA,
    # survey menstrual stop yes none
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_Q,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_MTA,
    # survery menstrual stop yes but hormone
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone_Q,
    age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone_MTA,
    # survey menstrual stop reason = natural menopause
    #               age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause,
    #               age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause_Q,
    #               age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause_MTA,
    # survey hysterectomy
    #               age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes,
    #               age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes_Q,
    #               age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes_MTA,
    # demographics
    # demographic survey
    #              age_at_demographic_survey,
    #              age_at_demographic_survey_Q,
    #              age_at_demographic_survey_MTA,
    #              # education survey 
    #              age_at_date_Education,
    #              age_at_date_Education_Q,
    #              age_at_date_Education_MTA,
    #              # income survey
    #              age_at_date_Income,
    #              age_at_date_Income_Q,
    #              age_at_date_Income_MTA,
    # demographic information
    ancestry_pred,
    Education,
    ethnicity,
    Income,
    race
  ) %>%
  names()

OneHot_Variables
Sociodemographic_Variables

# summary stats table of one-hot encoded menopause descriptors stratified by sociodemographic variables
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey <-
  OneHot_Variables %>%
  lapply(
    X = .,
    FUN = function(currentOneHotVariable)
    {
      
      TableToReturn <-
        Sociodemographic_Variables %>%
        lapply(
          X = .,
          FUN = function(currentDemographic)
          {
            
            DataToSummarize <-
              # select column for currentOneHotVariable and demographic
              Demographic_data_all_AoURP %>%
              select(
                .data = .,
                "currentVariable_oneHot" = all_of(x = currentOneHotVariable),
                "Group" = all_of(x = currentDemographic),
                everything()
              ) %>%
              # filter to presence (1) for the current variable
              filter(
                .data = .,
                currentVariable_oneHot==1
              ) %>%
              # remove one hot variable from table
              select(
                .data = .,
                -currentVariable_oneHot
              )
            
            # summarize the data only if there are any non-missing values in the group column
            if(!all(is.na(x = DataToSummarize$Group)))
            {
              
              
              
              
              # if the variable is not continuous age, compute sample sizes,
              # otherwise, compute measures of central tendency
              if(
                # NOT continous age
                !(
                  # contains age
                  grepl(pattern = "age",x = currentDemographic) & 
                  # and is NOT age quartile (Q) or menopause transition age (MTA)
                  !grepl(pattern = "_Q|_MTA",x = currentDemographic)
                )
                
                #currentDemographic!="age_from_birth_date_current_year"
              )
              {
                
                Categorical_Summary_table <-
                  DataToSummarize %>%
                  select(.data = .,Group) %>%
                  # compute sample sizes
                  table() %>%
                  data.frame() %>%
                  # label the descriptor, strata, and statistics
                  mutate(
                    .data = .,
                    Descriptor = currentOneHotVariable,
                    Strata = currentDemographic,
                    Statistic = "sample_size"
                  ) %>%
                  # rearrange columns
                  select(
                    .data = .,
                    Descriptor,
                    Strata,
                    Group,
                    Statistic,
                    "Sample_size_N_OR_stat_value" = Freq
                  ) %>%
                  # arrange rows alphabetically by group
                  arrange(
                    .data = .,
                    Group
                  )
                
                # set as the result to return
                TableToReturn <- Categorical_Summary_table
                
                # compute measures of central tendency for continous
              } else {
                
                
                # compute grand summary stats (no groups)
                Continuous_Summary_table_grand <-
                  DataToSummarize %>%
                  summarize(
                    .data = .,
                    Sample_size_N = n(), 
                    mean = mean(x = Group,na.rm = TRUE), 
                    sd = sd(x = Group,na.rm = TRUE), 
                    # min = min, (observations must be ≥ 20)
                    Q1 = quantile(Group, 0.25, na.rm = TRUE), 
                    median = median(x = Group,na.rm = TRUE), 
                    Q3 = quantile(Group, 0.75, na.rm = TRUE),
                    IQR = IQR(x = Group, na.rm = TRUE)#,   # Interquartile Range (Q3 - Q1)
                    # max = max (observations must be ≥ 20)
                    #Range = max(x = Group,na.rm = TRUE) - min(x = Group,na.rm = TRUE) # # Range as (Max - Min)
                  ) %>%
                  # transpose rows and columns
                  pivot_longer(
                    data = .,
                    cols = everything(), 
                    names_to = "Statistic", 
                    values_to = "Sample_size_N_OR_stat_value"
                  ) %>%
                  mutate(
                    .data = .,
                    # label the descriptor, strata, group, and statistics
                    Descriptor = currentOneHotVariable,
                    Strata = currentDemographic,
                    Group = "none",
                    # add "_grand" suffix to stat values
                    Statistic = Statistic %>% paste0(.,"_grand")
                  ) %>%
                  # rearrange columns 
                  select(
                    .data = .,
                    Descriptor,Strata,Group,Statistic,Sample_size_N_OR_stat_value
                  )
                
                
                Continuous_Summary_table_byGroup <-
                  # identify menopause transition age (MTA) and
                  # age quartile (Q) columns 
                  Demographic_data_all_AoURP %>%
                  names(x = .) %>%
                  grepl(pattern = "_MTA|_Q",x = .) %>%
                  which(x = .) %>%
                  names(x = Demographic_data_all_AoURP)[.] %>%
                  # add them to an array with the other non-continuous demographics
                  c(
                    .,
                    'ancestry_pred',
                    'Education',
                    'ethnicity',
                    'Income',
                    'race'
                  ) %>%
                  sort(x = .) %>%
                  # compute group variable summary stats by looping through categorical variables
                  lapply(
                    X = .,
                    FUN = function(currentVariable)
                    {
                      
                      
                      Continuous_Summary_table_byGroup <-
                        DataToSummarize %>%
                        select(
                          .data = .,
                          Group,
                          "Subgroup_demographic" = all_of(x = currentVariable)
                        ) %>%
                        group_by(
                          .data = .,
                          Subgroup_demographic
                        ) %>%
                        summarize(
                          .data = .,
                          Sample_size_N = n(), 
                          mean = mean(x = Group,na.rm = TRUE), 
                          sd = sd(x = Group,na.rm = TRUE), 
                          # min = min, (observations must be ≥ 20)
                          Q1 = quantile(Group, 0.25, na.rm = TRUE), 
                          median = median(x = Group,na.rm = TRUE), 
                          Q3 = quantile(Group, 0.75, na.rm = TRUE),
                          IQR = IQR(x = Group, na.rm = TRUE)#,   # Interquartile Range (Q3 - Q1)
                          # max = max (observations must be ≥ 20)
                          #Range = max(x = Group,na.rm = TRUE) - min(x = Group,na.rm = TRUE) # # Range as (Max - Min)
                        ) %>%
                        ungroup() %>%
                        # rename columns and rearrange
                        select(
                          .data = .,
                          "Group" = Subgroup_demographic,
                          everything()
                        ) %>%
                        # group split by group and pivot longer
                        group_by(.data = .,Group) %>%
                        group_split(.tbl = .) %>%
                        lapply(
                          X = .,
                          FUN = function(currentTable)
                          {
                            # save current group value to 
                            # add back to table after pivot
                            currentGroup <- currentTable$Group %>% unique(x = .)
                            
                            DataToReturn <-
                              currentTable %>%
                              select(
                                .data = .,
                                -Group
                              ) %>%
                              # transpose rows and columns
                              pivot_longer(
                                data = .,
                                cols = everything(), 
                                names_to = "Statistic", 
                                values_to = "Sample_size_N_OR_stat_value"
                              ) %>%
                              # add group indicator back to front of table
                              mutate(
                                .data = .,
                                Group = currentGroup,
                                # add "_byGroup" suffix to stat values
                                Statistic = Statistic %>% paste0(.,"_byGroup")
                              ) %>%
                              select(
                                .data = .,
                                Group,
                                everything()
                              )
                            
                            
                            return(DataToReturn)
                          }
                        ) %>%
                        do.call(
                          what = "rbind",
                          args = .
                        ) %>%
                        # make sure the group rows are sorted alphabetically
                        arrange(.data = .,Group) %>%
                        # add useful columns
                        mutate(
                          .data = .,
                          Descriptor = currentOneHotVariable,
                          Strata = currentDemographic
                        ) %>%
                        # rearrange columns
                        select(
                          .data = .,
                          Descriptor,
                          Strata,
                          Group,
                          Statistic,
                          Sample_size_N_OR_stat_value
                        ) %>%
                        # add the group meta label to individual subroups
                        mutate(
                          .data = .,
                          Group = Group %>% paste0(currentVariable,"_",.)
                        )
                      
                      
                      return(Continuous_Summary_table_byGroup)
                    }
                  ) %>%
                  do.call(
                    what = "rbind",
                    args = .
                  )
                
                # combine grand and by group continuous summary stat tables as table to return
                TableToReturn <- 
                  list(
                    Continuous_Summary_table_grand,
                    Continuous_Summary_table_byGroup
                  ) %>%
                  do.call(what = "rbind",args = .)
                
              }
              
              
            } else {
              
              TableToReturn <- NULL  
            }
            
            
            return(TableToReturn)
            
          }
        ) %>%
        do.call(what = "rbind",args = .)
      
      return(TableToReturn)
      
    }
  ) %>%
  do.call(
    what = "rbind",
    args = .
  ) %>%
  # removing values < 20 by disguising as "less_than_equal_20"
  mutate(
    .data = .,
    # if statistic column has sample size and Sample_size_N_OR_stat_value < 20,
    # update the value, otherwise use original
    N20_protect = if_else(
      condition = (Statistic=="Sample_size_N_grand" | Statistic=="Sample_size_N_byGroup"| Statistic=="sample_size") & 
        (Sample_size_N_OR_stat_value < 20),
      true = as.character(x = "less_than_equal_20"),
      false = as.character(x = Sample_size_N_OR_stat_value)
    )
  ) %>%
  # drop the original Sample_size_N_OR_stat_value column 
  select(
    .data = .,
    -Sample_size_N_OR_stat_value
  ) %>%
  # replace it with N20_protect column
  select(
    .data = .,
    everything(),
    "Sample_size_N_OR_stat_value" = N20_protect
  )


# identify column names
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey %>% names(x = .)

# view unique Statistic column values
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey$Statistic %>% 
  unique(x = .)

# view unique Sample_size_N_OR_stat_value column values
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey$Sample_size_N_OR_stat_value %>% 
  unique(x = .)

# preview the dataset
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey %>%
  head(x = .)

# save the resulting file to the file system
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey %>%
  write_tsv(
    x = .,
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_ageDateAdjust_femaleSexFilter.tsv"
  )

# check for less than 20
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey$Statistic %>% unique()

Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey %>%
  # filter to sample size values
  filter(
    .data = .,
    (Statistic=="Sample_size_N_grand") | 
      (Statistic=="Sample_size_N_byGroup") | 
      (Statistic=="sample_size")
  ) %>%
  pull(Sample_size_N_OR_stat_value) %>% 
  # print sorted sample sizes to screen to check
  unique() %>% 
  # convert to numeric
  as.numeric(x = .) %>%
  sort()

# load the summary statistics results file and summarize
library(tidyverse)

# load the summary statistics file
# save the resulting file to the file system
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey <-
  read.delim(
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_ageDateAdjust_femaleSexFilter.tsv",
    header = TRUE,
    sep = "\t"
  )

# clean up the strata and group labels to create a table for further analysis
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary <-
  Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey %>%
  # make sure sample size or stat value column is numeric,
  # with less than 20 values set to numeric NA
  mutate(
    .data = .,
    Sample_size_N_OR_stat_value = if_else(
      condition = Sample_size_N_OR_stat_value=="less_than_equal_20",
      true = as.character(x = NA),
      false = Sample_size_N_OR_stat_value
    )
  ) %>%
  mutate(
    .data = .,
    Sample_size_N_OR_stat_value = Sample_size_N_OR_stat_value %>%
      as.numeric(x = .)
  ) %>%
  # clean up strata labels
  mutate(
    Strata = Strata %>%
      tolower(x = .) %>%
      gsub(pattern = "^sex_at_birth$", replacement = "sex", x = .) %>%
      gsub(pattern = "^education$", replacement = "education level (EL)", x = .) %>%
      gsub(pattern = "^income$", replacement = "income level (IL)", x = .) #%>%
    #gsub(pattern = "age_q", replacement = "age", x= .)
  ) %>% 
  # clean the group labels
  mutate(
    Group = case_when(
      # age quartile (Q)
      Group == "^Q1$" ~ "Q1 (19-41)",
      Group == "^Q2$" ~ "Q2 (42-57)",
      Group == "^Q3$" ~ "Q3 (58-69)",
      Group == "^Q4$" ~ "Q4 (≥70)",
      # age (menopause transition age)
      Group == "^MTA1$" ~ "1.pre(<40)",
      Group == "^MTA2$" ~ "2.peri(40-60)",
      Group == "^MTA3$" ~ "3.post(≥60)",
      # education
      Group == "Highest Grade: Never Attended" ~ " EL1(none)",
      Group == "Highest Grade: One Through Four" ~ " EL2(≤K-4)",
      Group == "Highest Grade: Five Through Eight" ~ " EL3(≤K-8)",
      Group == "Highest Grade: Nine Through Eleven" ~ " EL4(≤K-11)",
      Group == "Highest Grade: Twelve Or GED" ~ " EL5(12/GED)",
      Group == "Highest Grade: College One to Three" ~ " EL6(≤college)",
      Group == "Highest Grade: College Graduate" ~ " EL7(col grad)",
      Group == "Highest Grade: Advanced Degree" ~ " EL8(adv deg)",
      Group == "PMI: Prefer Not To Answer" ~ "PNA",
      # ethnicity
      Group == "Hispanic or Latino" ~ "H-L",
      Group == "Not Hispanic or Latino" ~ "Non-H-L",
      Group == "What Race Ethnicity: Race Ethnicity None Of These" ~ "None",
      # gender
      Group == "Gender Identity: Additional Options" ~ "Additional",
      Group == "Gender Identity: Non Binary" ~ "non-Bi",
      Group == "Gender Identity: Transgender" ~ "Trans",
      Group == "Not man only, not woman only, prefer not to answer, or skipped" ~ "NB|PNA|Skip",
      # income level (IL)
      Group == "Annual Income: less 10k" ~ "IL1 (<10k)",
      Group == "Annual Income: 10k 25k" ~ "IL2 (≤25k)",
      Group == "Annual Income: 25k 35k" ~ "IL3 (≤35k)",
      Group == "Annual Income: 35k 50k" ~ "IL4 (≤50k)",
      Group == "Annual Income: 50k 75k" ~ "IL5 (≤75k)",
      Group == "Annual Income: 75k 100k" ~ "IL6 (≤100k)",
      Group == "Annual Income: 100k 150k" ~ "IL7 (≤150k)",
      Group == "Annual Income: 150k 200k" ~ "IL8 (≤200k)",
      Group == "Annual Income: more 200k" ~ "IL9 (200k+)",
      # race
      Group == "American Indian or Alaska Native" ~ "AIAN",
      Group == "Asian" ~ "Asian",
      Group == "Black or African American" ~ "Black-AA",
      Group == "Middle Eastern or North African" ~ "MENA",
      Group == "More than one population" ~ "Multiple",
      Group == "None Indicated" ~ "None",
      Group == "None of these" ~ "None",
      Group == "Native Hawaiian or Other Pacific Islander" ~ "NH-PI",
      # sex
      Group == "Female" ~ "F",
      Group == "I prefer not to answer" ~ "PNA",
      Group == "Male" ~ "M",
      Group == 'No matching concept' ~ "No match",
      Group == 'PMI: Skip' ~ 'Skip',
      Group == 'Sex At Birth: Sex At Birth None Of These' ~ 'Sex none',
      TRUE ~ Group  # Keeps original value if no match is found
    ))

# ancestry age summary (full cohort female sex)
#Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>% head()
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  filter(.data = .,grepl(pattern = "Demographic_AoURP_all_yes",x = Descriptor)) %>%
  filter(.data = .,Strata=="age_at_demographic_survey") %>%
  filter(.data = .,grepl(pattern = "ancestry_pred",x = Group)) %>%
  group_by(.data = .,Group) %>%
  pivot_wider( 
    data = .,
    names_from = Statistic,
    values_from =  Sample_size_N_OR_stat_value
  )

# age summary stats of survey menstrual stop yes variables
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  filter(
    .data = .,
    (
      (Descriptor=="surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_But_Hormone") & 
        (Strata=="age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_but_hormone")
    ) |
      (
        (Descriptor=="surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None") & 
          (Strata=="age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none")
      )
  ) %>%
  filter(
    .data = .,
    Group=="none"
  )


# age summary stats of survey menstrual stop yes variables
Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  filter(
    .data = .,
    (Descriptor=="surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None") &
      (Strata=="age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none_mta")
  ) 

# identify sample sizes of menopause transition age groups for hysterectomy = yes
MTA_hysterectomy_sampleSize <- 
  Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  # filter to hysterectomy = yes
  filter(
    .data = .,
    Descriptor=="surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes"
  ) %>%
  # filter to menopause transition ages
  filter(
    .data = .,
    (Group=="age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes_MTA_MTA1") |
      (Group=="age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes_MTA_MTA2") |
      (Group=="age_at_date_surveyQ_Overall_Health_Hysterectomy_History_Hysterectomy_History_Yes_MTA_MTA3")
  ) %>%
  # filter to hysterectomy = yes
  filter(
    .data = .,
    Strata=="age_at_date_surveyq_overall_health_hysterectomy_history_hysterectomy_history_yes"
  ) %>%
  unique() %>%
  filter(
    .data = .,
    Statistic=="Sample_size_N_byGroup"
  ) %>%
  # round to nearest 5
  mutate(
    .data = .,
    N_rounded = ceiling(as.numeric(Sample_size_N_OR_stat_value) / 5) * 5
  ) %>%
  # calculate percent of total
  mutate(
    .data = .,
    Percent = (N_rounded/sum(N_rounded))*100
  )

MTA_hysterectomy_sampleSize

# identify sample sizes for natural menopause
MTA_natural_sampleSize <- 
  Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  # filter to natural menopause
  filter(
    .data = .,
    Descriptor=="surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause"
  ) %>%
  # filter to menopause transition ages
  filter(
    .data = .,
    (Group=="age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause_MTA_MTA1") |
      (Group=="age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause_MTA_MTA2") |
      (Group=="age_at_date_surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause_MTA_MTA3")
  ) %>%
  # filter to natural menopause
  filter(
    .data = .,
    Strata=="age_at_date_surveyq_yes_none_menstrual_stopped_reason_menstrual_stopped_reason_natural_menopause"
  ) %>%
  unique() %>%
  filter(
    .data = .,
    Statistic=="Sample_size_N_byGroup"
  ) %>%
  # round to nearest 5
  mutate(
    .data = .,
    N_rounded = ceiling(as.numeric(Sample_size_N_OR_stat_value) / 5) * 5
  ) %>%
  # calculate percent of total
  mutate(
    .data = .,
    Percent = (N_rounded/sum(N_rounded))*100
  )

MTA_natural_sampleSize

Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  filter(.data = .,Descriptor=="surveyQ_Yes_None_Menstrual_Stopped_Reason_Menstrual_Stopped_Reason_Natural_Menopause") %>%
  pull(Group) %>%
  unique()

# create nice table of sample sizes of menopause variables in survey and EHR without any stratification
Menopause_descriptor_sample_sizes_noStrata <- 
  # get sample sizes of non-stratified EHR and survey data and aggregate into more general categories
  Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  # filter to conditionEHR_ and surveyQ_ columns
  filter(
    .data = .,
    grepl(pattern = "conditionEHR_|surveyQ_",x = Descriptor)
  ) %>%
  # filter to non-stratified results, total sample size
  filter(
    Group=="none" & Statistic=="Sample_size_N_grand"
  ) %>%
  # remove unneccessary columns
  select(
    Descriptor,
    Sample_size_N_OR_stat_value
  ) %>%
  # filter to unique rows
  distinct() %>%
  # extract the data modality to a column
  mutate(
    .data = .,
    Data_modality = case_when(
      grepl(pattern = "conditionEHR_",x = Descriptor) ~ "EHR",
      grepl(pattern = "surveyQ_",x = Descriptor) ~ "survey"
    )
  ) %>%
  # clean descriptor column
  mutate(
    Descriptor = Descriptor %>%
      gsub(pattern = "conditionEHR_",replacement = "",x = .) %>%
      gsub(pattern = "surveyQ_",replacement = "",x = .) %>%
      gsub(pattern = "Overall_Health_",replacement = "",x = .) %>%
      gsub(pattern = "_SNOMED",replacement = "",x = .) %>%
      gsub(pattern = "_",replacement = " ",x = .)
  ) %>%
  # sort sample size column so less than 20 at bottom
  arrange(Sample_size_N_OR_stat_value) %>%
  # aggregate similar descriptors
  mutate(
    Descriptor_aggregate = case_when(
      # EHR menopause
      grepl("Menopause present|Premature menopause", Descriptor) ~ "Menopause Total EHR",
      # EHR ovarian failure
      grepl("ovarian failure", Descriptor) ~ "Ovarian failure Total EHR",
      # EHR vasomotor
      grepl("vasomotor", Descriptor) ~ "Vasomotor symptoms",
      # survey yes ovary removal history
      (grepl("Ovary Removal History",Descriptor) & 
         grepl("Yes",Descriptor)) ~ "Ovary removal history total yes",
      TRUE ~ Descriptor  # Keeps the original value if no condition matches
    )
  ) %>%
  # replace missing sample sizes with zero
  mutate(
    Sample_size_N_OR_stat_value = Sample_size_N_OR_stat_value %>% 
      as.numeric(x = .) %>%
      # mark the less than 20 with 0 so they sort correctly
      replace_na(0)
  ) %>%
  # if the sample size is < 20, round to 20
  # if the sample size is >=20, round up to nearest 5
  mutate(
    Sample_size_N_OR_stat_value = case_when(
      Sample_size_N_OR_stat_value < 20 ~ 20,
      TRUE ~ ceiling(Sample_size_N_OR_stat_value / 5) * 5
    )
  ) %>%
  # compute aggregate sample size where possible
  group_by(Descriptor_aggregate) %>%
  mutate(
    .data = .,
    Descriptor_aggregate_sample_size = Sample_size_N_OR_stat_value %>%
      as.numeric(x = .) %>%
      sum(.,na.rm = TRUE)
  ) %>%
  ungroup() %>%
  # rearrange columns
  select(
    .data = .,
    Data_modality,
    Descriptor_aggregate,
    Descriptor_aggregate_sample_size,
    Descriptor,
    Sample_size_N_OR_stat_value
  ) %>%
  # sort the table rows
  arrange(
    .data = .,
    desc(x = Data_modality),
    desc(x = Descriptor_aggregate_sample_size),
    desc(x = Sample_size_N_OR_stat_value)
  ) %>%
  # convert sample size column to character vector
  mutate(
    .data = .,
    Sample_size_N_OR_stat_value = Sample_size_N_OR_stat_value %>%
      as.character(x = .)
  ) %>%
  # convert values of "20" to "N ≤ 20"
  mutate(
    .data = .,
    Sample_size_N_OR_stat_value = if_else(
      condition = Sample_size_N_OR_stat_value == "20",
      true = "N ≤ 20",
      false = Sample_size_N_OR_stat_value
    )
  )

Menopause_descriptor_sample_sizes_noStrata

# save the table
Menopause_descriptor_sample_sizes_noStrata %>%
  write_tsv(
    x = .,
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Table1_Menopause_descriptor_sample_sizes_noStrata.tsv"
  )


Menopause_descriptor_sample_sizes_noStrata %>%
  filter(.data = .,Data_modality=="EHR")

N_EHR_menopausePresent_and_premature <-
  # number of females with both menopause present AND premature menopause codes
  Demographic_data_all_AoURP %>%
  select(
    .data = .,
    person_id,
    conditionEHR_Menopause_present_289903006_SNOMED,
    conditionEHR_Premature_menopause_373717006_SNOMED
  ) %>%
  filter(
    .data = .,
    (conditionEHR_Menopause_present_289903006_SNOMED==1) & 
      (conditionEHR_Premature_menopause_373717006_SNOMED==1)
  ) %>%
  nrow(x = .)

N_EHR_menopausePresent_and_premature

### create the demographic summary table for the manuscript
Demographic_summary_stats_table <-
  Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  filter(
    .data = .,
    Descriptor=="Demographic_AoURP_all_yes"
  ) %>%
  filter(
    .data = .,
    Strata %in% 
      c(
        'age_at_demographic_survey'
      )
  ) %>%
  filter(
    .data = .,
    grepl(pattern = "none",x = Group) |
      grepl(pattern = "age_at_demographic_survey_",x = Group) |
      grepl(pattern = "^Education_",x = Group) |
      grepl(pattern = "ethnicity_",x = Group) |
      grepl(pattern = "gender_",x = Group) |
      grepl(pattern = "^Income_",x = Group) |
      grepl(pattern = "race_",x = Group) |
      grepl(pattern = "sex_at_birth_",x = Group) |
      grepl(pattern = "ancestry_pred_",x = Group)
  ) %>%
  filter(
    .data = .,
    grepl(pattern = "Sample_size_N_",x = Statistic) |
      grepl(pattern = "Q1_",x = Statistic) |
      grepl(pattern = "median_",x = Statistic) |
      grepl(pattern = "Q3_",x = Statistic) |
      grepl(pattern = "IQR_",x = Statistic)
  ) %>%
  group_split(Group) %>%
  lapply(
    X = .,
    FUN = function(currentGroupTable)
    {
      TableToReturn <-
        currentGroupTable %>%
        pivot_wider(
          data = .,
          names_from = Statistic,
          values_from = Sample_size_N_OR_stat_value
        )
      
      # update the column names to be all the same
      names(x = TableToReturn) <-
        c("Descriptor","Strata","Group","Sample_size_N","Q1","median","Q3","IQR")
      
      return(TableToReturn)
    }
  ) %>%
  # bind results by row
  do.call(what = "rbind",args = .) %>%
  # remove descriptor and strata columns
  select(
    .data = .,
    -Descriptor,-Strata
  ) %>%
  # if the sample size is < 20, round to 20
  # if the sample size is >=20, round up to nearest 5
  mutate(
    Sample_size_N = case_when(
      Sample_size_N < 20 ~ 20,
      TRUE ~ ceiling(Sample_size_N / 5) * 5
    )
  ) %>%
  # convert group text to lower case
  mutate(
    .data = .,
    Group = Group %>% tolower(x = .)
  ) %>%
  # sort by group
  arrange(.data = .,Group) %>%
  # remove NA sample size groups
  filter(
    .data = .,
    !is.na(x = Sample_size_N)
  )

# view the table
Demographic_summary_stats_table

# save the table to the file system
Demographic_summary_stats_table %>%
  write_tsv(
    x = .,
    file = "./MenoSummaryStats_CUWHC_poster_VERSION8/Table2_Demographic_summary_stats_table.tsv"
  )

library(grid)

Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  # filter to sample size data only, no continuous summary stats (to make barchart),
  # within the demographic groups only
  filter(
    .data = .,
    Statistic=="sample_size"
  ) %>%
  # filter to descriptors of interest for plots
  filter(
    .data = .,
    (Descriptor == "intersect3_srWGS_EHR_menopauseCode_Survey_menopauseQuestion_all_yes") |
      (Descriptor == "Demographic_AoURP_all_yes") |
      (Descriptor == "EHR_menopauseCode_all_yes") |
      (Descriptor == "Survey_menopauseQuestion_all_yes")
  ) %>%
  # remove no longer needed columns
  select(
    .data = .,
    -Statistic
  ) %>%
  # make sure the sample size is numeric
  mutate(
    .data = .,
    Sample_size_N_OR_stat_value = Sample_size_N_OR_stat_value %>%
      as.numeric(x = .)
  ) %>%
  # if the value for the sample size is NA, meaning it was ≤ 20 and omitted, mark with a numeric 0 to plot
  mutate(
    .data = .,
    Sample_size_N_OR_stat_value = if_else(
      condition = is.na(x = Sample_size_N_OR_stat_value),
      true = as.numeric(x = 0),
      false = as.numeric(x = Sample_size_N_OR_stat_value)
    )
  ) %>%
  # round the sample size numbers up to the nearest 5,
  # anything with a value of 0 (used for N < 20) will be converted to a value of 5
  mutate(
    Sample_size_N_OR_stat_value = if_else(
      condition = Sample_size_N_OR_stat_value == 0,
      true = 5,
      false = ceiling(Sample_size_N_OR_stat_value/5)*5
    )
  ) %>%
  # filter to strata of interest
  filter(
    .data = .,
    Strata %in% c(
      # age categories general demographic
      'age_at_demographic_survey_q','age_at_demographic_survey_mta',
      # age categories EHR menopause
      'age_at_date_conditionehr_menopause_present_289903006_snomed_q',
      'age_at_date_conditionehr_menopause_present_289903006_snomed_mta',
      # age categories survey menopause 
      'age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none_q',
      'age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none_mta',
      # other demographic info
      'ancestry_pred','education level (EL)','ethnicity',
      #'gender',
      'income level (IL)','race'#,
      #'sex'
    )
  ) %>%
  # group the data by the descriptor
  group_by(
    .data = .,
    Descriptor
  ) %>%
  # group split into list of dataframes for each descriptor
  group_split() %>%
  lapply(
    X = .,
    FUN = function(currentDescriptorDataframe)
    {
      
      # identify label for current descriptor
      currentDescriptor <-
        currentDescriptorDataframe$Descriptor %>% unique(x = .)
      print(currentDescriptor)
      
      # define an array of StrataToSelect for plotting
      StrataToSelect <- 
        c(
          'ancestry_pred','education level (EL)','ethnicity',
          #'gender',
          'income level (IL)','race'#,'sex'
        )
      
      # select the proper age quartiles and MTAs based on the currentDescriptor
      
      # for survey or intersect 3 (EHR, survey, genome sequence) use the menopause survey ages
      if(
        currentDescriptor == "intersect3_srWGS_EHR_menopauseCode_Survey_menopauseQuestion_all_yes" | 
        currentDescriptor == "Survey_menopauseQuestion_all_yes"
      )
      {
        # select ages for the menstrual stopped survey question
        StrataToSelect <- 
          StrataToSelect %>%
          c(
            .,
            "age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none_q",
            "age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none_mta"
          )
        
      } 
      # for general demographic data use the demographic ages
      else if (currentDescriptor == "Demographic_AoURP_all_yes") 
      {
        # select proper ages for the demographic data
        StrataToSelect <- 
          StrataToSelect %>%
          c(
            .,
            'age_at_demographic_survey_q',
            'age_at_demographic_survey_mta'
          )
        
        # for menopause EHR, use the corresponding ages    
      } else if (currentDescriptor == "EHR_menopauseCode_all_yes")
      {
        # select ages for the menopause EHR code
        StrataToSelect <- 
          StrataToSelect %>%
          c(
            .,
            'age_at_date_conditionehr_menopause_present_289903006_snomed_q',
            'age_at_date_conditionehr_menopause_present_289903006_snomed_mta'
          )
      }
      # otherwise, print a message that an unaccounted for descriptor was included in the analysis
      else 
      {
        print("**************UNACCOUNTED FOR DESCRIPTOR INCLUDED IN ANALYSIS******************")
      } 
      
      PlotTitle <- currentDescriptor
      
      # define data to be plotted for current descriptor
      InputDataForPlot <-
        currentDescriptorDataframe %>%
        # filter to the strata to select
        filter(
          .data = .,
          Strata %in% StrataToSelect
        ) %>%
        # clean up ancestry label
        mutate(
          .data = .,
          Strata = case_when(
            Strata=="ancestry_pred" ~ "ancestry",
            TRUE ~ Strata
          )
        ) %>%
        # clean up age category labels
        mutate(
          .data = .,
          Strata = case_when(
            grepl("_q$", Strata) ~ "age",
            grepl("_mta$", Strata) ~ "age (MT)",
            TRUE ~ Strata
          )
        ) %>%
        mutate(
          .data = .,
          Group = case_when(
            # menopause age
            Group=="MTA1" ~ "1.pre(<40)",
            Group=="MTA2" ~ "2.peri(40-60)",
            Group=="MTA3" ~ "3.post(≥60)",
            # age quartile
            Group == "Q1" ~ "Q1 (19-41)",
            Group == "Q2" ~ "Q2 (42-57)",
            Group == "Q3" ~ "Q3 (58-69)",
            Group == "Q4" ~ "Q4 (≥70)",
            # genetic ancestry
            Group == "afr" ~ "AFR-like",
            Group == "amr" ~ "AMR-like",
            Group == "eas" ~ "EAS-like",
            Group == "eur" ~ "EUR-like",
            Group == "mid" ~ "MID-like",
            Group == "sas" ~ "SAS-like",
            TRUE ~ Group
          )
        ) %>%
        # control for any duplicate group and strata labels after modifying them
        group_by(Strata,Group) %>%
        mutate(
          .data = .,
          Sample_size_N_OR_stat_value = Sample_size_N_OR_stat_value %>% sum(.,na.rm = TRUE)
        ) %>%
        ungroup() %>%
        unique()
      
      
      ### create a plot of all sample sizes of each strata and group
      # for single menopause descriptors (all other strata groups in same plot)
      
      # extract colors for each strata level
      strata_levels <-
        InputDataForPlot$Strata %>%
        unique(x = .) %>%
        sort()
      
      strata_colors <-
        scale_fill_viridis_d()$palette(length(x = strata_levels))
      
      # Create a named vector for easy mapping
      strata_color_map <- setNames(strata_colors, strata_levels)
      
      InputDataForPlot <-
        InputDataForPlot %>%
        # set any sample sizes with missing value or value less than 20 to value of 20 for plotting
        # to be given the ≤20 label and be shown at value of 20 on plot
        mutate(
          .data = .,
          Sample_size_N_OR_stat_value = if_else(
            condition = (is.na(x = Sample_size_N_OR_stat_value)) | (Sample_size_N_OR_stat_value<=20),
            true = as.numeric(x = 20),
            false = as.numeric(x = Sample_size_N_OR_stat_value)
          )
        )
      
      # save the table of data that corresponds to the current plot
      InputDataForPlot %>%
        write_tsv(
          x = .,
          file = paste0(
            "./MenoSummaryStats_CUWHC_poster_VERSION8/",
            "SampleSize_Descriptor_allStrataAllgroups_",
            currentDescriptor,
            ".tsv"
          )
        )
      
      # identify max sample size with percentage buffer for upper y-axis limit
      MaxSampleSizeBuffer <-
        max(InputDataForPlot$Sample_size_N_OR_stat_value,na.rm = TRUE)+
        (max(InputDataForPlot$Sample_size_N_OR_stat_value,na.rm = TRUE)*0.1)
      
      PlotDesciptorAllStrataGroups <-
        # create a barchart of sample size by demographic groupings
        InputDataForPlot %>%
        ggplot(
          mapping = aes(
            x = Group,
            y = Sample_size_N_OR_stat_value,
            fill = Strata
          )
        ) +
        geom_bar(
          stat = 'identity',
          position = position_dodge(width = 5),
          width = 0.9,
          color = "black",
          linewidth = 0.1
        ) +
        geom_text(
          hjust = -0.1,
          vjust = 0.5,
          aes(
            y = Sample_size_N_OR_stat_value,
            label = Sample_size_N_OR_stat_value
          ),
          color = "black",
          size = 4,
          fontface = "bold", 
          angle = 90
        ) +
        facet_grid(
          Descriptor ~ Strata,
          scales = "free",
          space = "free_x",
          switch = "x",
          labeller = labeller(Descriptor = label_wrap_gen(width = 5))
        ) +
        scale_y_continuous(
          labels = scales::comma,
          breaks = seq(0,500000,10000),
          expand = c(0,0),
          limits = c(NA,MaxSampleSizeBuffer),
          name = paste0("Sample size (N)","\n")
        ) +
        scale_fill_viridis_d() +
        guides(fill = "none") +
        labs(title = PlotTitle) +
        theme_classic() +
        theme(
          #plot.title = element_text(hjust = 0.5, size = 7, face = "bold"),
          plot.title = element_blank(),
          axis.title.y = element_text(size = 14,face="bold"),
          axis.text.y = element_text(face = "bold", size = 14),
          axis.text.x = element_text(angle = 45, hjust = 1,face = "bold",size = 14),
          legend.position = "none",
          legend.background = element_blank(),
          legend.text = element_text(size = 8),
          axis.title.x = element_blank(),
          strip.text.y = element_blank(),
          strip.text.x = element_text(
            face = "bold",colour = "white",size = 14
          ),
          strip.background.x = element_rect(fill = "white"), # placeholder to be modified dynamically
          panel.grid.major.y = element_line(color = "grey", linewidth = 0.2), # Add thin grey horizontal grid lines
          panel.grid.major.x = element_blank(), # Optional: remove vertical grid lines
          panel.grid.minor = element_blank(),    # Remove minor grid lines
          panel.spacing.x = unit(0, "lines"),
          panel.spacing.y = unit(0.25, "lines"),
          plot.margin = margin(0, 0, 0, 0, "cm") # Set plot margins to the smallest possible
        )
      
      # Modify the plot to update strip background colors
      PlotDesciptorAllStrataGroups_colorStrata <- ggplotGrob(PlotDesciptorAllStrataGroups)
      
      # Locate the strip background grobs
      strip_index <- which(grepl("strip-b", PlotDesciptorAllStrataGroups_colorStrata$layout$name))
      
      for (i in strip_index) {
        strip_label <- PlotDesciptorAllStrataGroups_colorStrata$grobs[[i]]$grobs[[1]]$children[[2]]$children[[1]]$label
        PlotDesciptorAllStrataGroups_colorStrata$grobs[[i]]$grobs[[1]]$children[[1]]$gp$fill <- strata_color_map[strip_label]
      }
      
      # Draw the plot
      grid.newpage()
      grid.draw(PlotDesciptorAllStrataGroups_colorStrata)
      
      # save the plot
      ggsave(
        plot = PlotDesciptorAllStrataGroups_colorStrata,
        units = "px",
        path = "./MenoSummaryStats_CUWHC_poster_VERSION8/",
        filename = paste0(
          "SampleSize_Descriptor_allStrataAllgroups_",
          currentDescriptor,
          ".png"
        ),
        width = 5500,
        height = 2750
      )
      
      return(currentDescriptor)
    }
  )

Age_comparison_menopause_EHR_survey_femaleSex <- 
  ### compare the ages distributions of the EHR menopause and the survey menopause
  Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  # filter to age summary data for EHR and survey menopause
  filter(
    .data = .,
    Descriptor=="EHR_menopauseCode_all_yes" | Descriptor=="Survey_menopauseQuestion_all_yes"
  ) %>%
  filter(
    .data = .,
    (Descriptor=="EHR_menopauseCode_all_yes" & Strata=="age_at_date_conditionehr_menopause_present_289903006_snomed") |
      (Descriptor=="Survey_menopauseQuestion_all_yes" & Strata=="age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none")
  ) %>%
  filter(
    .data = .,
    Group=="none"
  ) %>%
  filter(
    .data = .,
    Statistic!="mean_grand" & Statistic!="sd_grand"
  ) %>%
  pivot_wider(
    data = .,
    names_from = Statistic,
    values_from = Sample_size_N_OR_stat_value
  ) %>%
  select(
    .data = .,
    -Strata,
    -Group
  ) %>%
  filter(
    .data = .,
    Sample_size_N_grand > 20
  )

Age_comparison_menopause_EHR_survey_femaleSex

##### create median and IQR age plots for descriptors of interest stratified by demographics
Groups_of_interest_ages <-
  c(
    'none',
    # menopause EHR age groups
    'age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_MTA_MTA1',
    'age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_MTA_MTA2',
    'age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_MTA_MTA3',
    'age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_Q_Q1',
    'age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_Q_Q2',
    'age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_Q_Q3',
    'age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_Q_Q4',
    # menopause survey age groups
    'age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_MTA_MTA1',
    'age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_MTA_MTA2',
    'age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_MTA_MTA3',
    'age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_Q_Q1',
    'age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_Q_Q2',
    'age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_Q_Q3',
    'age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_Q_Q4',
    # general demographic data age groups
    'age_at_demographic_survey_MTA_MTA1',
    'age_at_demographic_survey_MTA_MTA2',
    'age_at_demographic_survey_MTA_MTA3',
    'age_at_demographic_survey_Q_Q1',
    'age_at_demographic_survey_Q_Q2',
    'age_at_demographic_survey_Q_Q3',
    'age_at_demographic_survey_Q_Q4'
  )

Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  # filter to descriptors of interest for plots
  filter(
    .data = .,
    (Descriptor == "intersect3_srWGS_EHR_menopauseCode_Survey_menopauseQuestion_all_yes") |
      (Descriptor == "Demographic_AoURP_all_yes") |
      (Descriptor == "EHR_menopauseCode_all_yes") |
      (Descriptor == "Survey_menopauseQuestion_all_yes")
  ) %>%
  # select corresponding age strata
  filter(
    .data = .,
    (Strata=="age_at_date_conditionehr_menopause_present_289903006_snomed") |
      (Strata=="age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none") |
      (Strata=="age_at_demographic_survey")
  ) %>%
  # select groups of interest
  filter(
    .data = .,
    (Group %in% Groups_of_interest_ages) |
      grepl(pattern = "^ancestry_pred_",x = Group) |
      grepl(pattern = "^Education_",x = Group) |
      grepl(pattern = "^ethnicity_",x = Group) |
      #grepl(pattern = "^gender_",x = Group) |
      grepl(pattern = "^Income_",x = Group) |
      grepl(pattern = "^race_",x = Group) #|
    #grepl(pattern = "^sex_at_birth_",x = Group)
  ) %>%
  # make statistic labels consistent
  mutate(
    .data = .,
    Statistic = Statistic %>%
      gsub(pattern = "_grand|_byGroup",replacement = "")
  ) %>%
  # make sure the stat column is numeric 
  mutate(
    .data = .,
    Sample_size_N_OR_stat_value = Sample_size_N_OR_stat_value %>% as.numeric(x = .)
  ) %>%
  # pivot so descriptive stats have their own column
  pivot_wider(
    names_from = Statistic,
    values_from = Sample_size_N_OR_stat_value
  ) %>%
  # make sure proper numerics for summary stats
  mutate(
    .data = .,
    across(c(Q1, median, Q3, mean), as.numeric)
  ) %>%
  # split the Group column into general category and specific group
  # by parsing the Group column
  mutate(
    .data = .,
    Group_general = Group %>%
      lapply(
        X = .,
        FUN = function(currentGroup)
        {
          if(currentGroup!="none")
          {
            # split string into array by underscore
            StringArray <-
              currentGroup %>%
              str_split(string = .,pattern = "_") %>%
              unlist(x = .)
            
            # find length of array
            ArrayLength <-
              StringArray %>%
              length(x = .)
            
            ValueToReturn <-
              # keep everything except last array element
              c(1:ArrayLength-1) %>%
              StringArray[.] %>%
              paste(.,collapse = "_")
            
            
          } else {
            ValueToReturn <- currentGroup
          }
          
          return(ValueToReturn)
        }
      ) %>%
      unlist(x = .)
  ) %>%
  mutate(
    .data = .,
    Group_specific = Group %>%
      lapply(
        X = .,
        FUN = function(currentGroup)
        {
          if(currentGroup!="none")
          {
            # split string into array by underscore
            StringArray <-
              currentGroup %>%
              str_split(string = .,pattern = "_") %>%
              unlist(x = .)
            
            # find length of array
            ArrayLength <-
              StringArray %>%
              length(x = .)
            
            ValueToReturn <-
              # keep last array element only
              ArrayLength %>%
              StringArray[.]
            
            
          } else {
            ValueToReturn <- currentGroup
          }
          
          return(ValueToReturn)
        }
      ) %>%
      unlist(x = .)
  ) %>%
  # clean up strata labels
  mutate(
    Group_general =   Group_general %>%
      tolower(x = .) %>%
      gsub(pattern = "ancestry_pred", replacement = "ancestry", x = .) %>%
      gsub(pattern = "_at_birth", replacement = "", x = .) %>%
      gsub(pattern = "education", replacement = "education level (EL)", x = .) %>%
      gsub(pattern = "income", replacement = "income level (IL)", x = .) %>%
      gsub(pattern = "none", replacement = "*All", x= .)
  ) %>% 
  # clean up group specific labels
  mutate(
    .data = .,
    Group_specific = case_when(
      # total
      Group_specific == "none" ~ "All",
      # age quartile
      Group_specific == "Q1" ~ "Q1 (19-41)",
      Group_specific == "Q2" ~ "Q2 (42-57)",
      Group_specific == "Q3" ~ "Q3 (58-69)",
      Group_specific == "Q4" ~ "Q4 (≥70)",
      # age (menopause)
      Group_specific == "MTA1" ~ "   1.pre(<40)",
      Group_specific == "MTA2" ~ "   2.peri(40-60)",
      Group_specific == "MTA3" ~ "   3.post(≥60)",
      # education
      Group_specific == "Highest Grade: Never Attended" ~ "   EL1(none)",
      Group_specific == "Highest Grade: One Through Four" ~ "   EL2(≤K-4)",
      Group_specific == "Highest Grade: Five Through Eight" ~ "   EL3(≤K-8)",
      Group_specific == "Highest Grade: Nine Through Eleven" ~ "   EL4(≤K-11)",
      Group_specific == "Highest Grade: Twelve Or GED" ~ "   EL5(12/GED)",
      Group_specific == "Highest Grade: College One to Three" ~ "   EL6(≤col)",
      Group_specific == "Highest Grade: College Graduate" ~ "   EL7(col grad)",
      Group_specific == "Highest Grade: Advanced Degree" ~ "   EL8(adv deg)",
      Group_specific == "PMI: Prefer Not To Answer" ~ "PNA",
      Group_specific == "PMI: Skip" ~ "Skip",
      # ethnicity
      Group_specific == "Hispanic or Latino" ~ "H-L",
      Group_specific == "Not Hispanic or Latino" ~ "Non-H-L",
      Group_specific == "What Race Ethnicity: Race Ethnicity None Of These" ~ "None",
      Group_specific == "No matching concept" ~ "No match",
      # income level (IL)
      Group_specific == "Annual Income: less 10k" ~ "IL1 (<10k)",
      Group_specific == "Annual Income: 10k 25k" ~ "IL2 (≤25k)",
      Group_specific == "Annual Income: 25k 35k" ~ "IL3 (≤35k)",
      Group_specific == "Annual Income: 35k 50k" ~ "IL4 (≤50k)",
      Group_specific == "Annual Income: 50k 75k" ~ "IL5 (≤75k)",
      Group_specific == "Annual Income: 75k 100k" ~ "IL6 (≤100k)",
      Group_specific == "Annual Income: 100k 150k" ~ "IL7 (≤150k)",
      Group_specific == "Annual Income: 150k 200k" ~ "IL8 (≤200k)",
      Group_specific == "Annual Income: more 200k" ~ "IL9 (200k+)",
      # race
      Group_specific == "American Indian or Alaska Native" ~ "AIAN",
      Group_specific == "Black or African American" ~ "Black-AA",
      Group_specific == "I prefer not to answer" ~ "PNA",
      Group_specific == "Middle Eastern or North African" ~ "MENA",
      Group_specific == "More than one population" ~ "Multiple",
      Group_specific == "None Indicated" ~ "None_1",
      Group_specific == "None of these" ~ "None_2",
      Group_specific == "Native Hawaiian or Other Pacific Islander" ~ "NH-PI",
      # sex
      Group_specific == "Female" ~ "F",
      Group_specific == "Male" ~ "M",
      Group_specific == "Sex At Birth: Sex At Birth None Of These" ~ "Sex none",
      # gender
      Group_specific == "Gender Identity: Additional Options" ~ "Additional",
      Group_specific == "Gender Identity: Non Binary" ~ "non-Bi",
      Group_specific == "Gender Identity: Transgender" ~ "Trans",
      Group_specific == "Not man only, not woman only, prefer not to answer, or skipped" ~ "NB|PNA|Skip",
      # genetic ancestry
      Group_specific == "afr" ~ "AFR-like",
      Group_specific == "amr" ~ "AMR-like",
      Group_specific == "eas" ~ "EAS-like",
      Group_specific == "eur" ~ "EUR-like",
      Group_specific == "mid" ~ "MID-like",
      Group_specific == "sas" ~ "SAS-like",
      TRUE ~ Group_specific  # Keeps original value if no match is found
    )
  )%>%
  # remove NA group specific
  filter(
    .data = .,
    Group_specific!='NA'
  ) %>%
  filter(
    .data = .,
    !is.na(x = Group_specific)
  ) %>%
  ### create a box-plot of age summary data (quartile 1 through 3 and median, no min and max)
  # for single menopause descriptors (all other strata groups in same plot)
  group_by(.data = .,Descriptor) %>%
  group_split() %>%
  # split the age summary stats data into list of dataframes by descriptor
  lapply(
    X = .,
    FUN = function(InputDataForPlot)
    {
      
      # identify current descriptor
      currentDescriptor <- InputDataForPlot$Descriptor %>% unique()
      
      
      # if the Descriptor is the intersect-3 or the survey menopause question, 
      # use the survey menopause age strata
      if(
        (currentDescriptor=="intersect3_srWGS_EHR_menopauseCode_Survey_menopauseQuestion_all_yes") |
        (currentDescriptor == "Survey_menopauseQuestion_all_yes") 
      ) 
      {
        
        # filter to the "age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none"
        InputDataForPlot <-
          InputDataForPlot %>%
          filter(
            .data = .,
            Strata=="age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none"
          ) %>%
          filter(
            .data = .,
            grepl(
              pattern = 
                "age_at_date_surveyQ_Overall_Health_Menstrual_Stopped_Menstrual_Stopped_Yes_None_|none|Education_|ethnicity_|Income_|race_|ancestry_pred_",
              Group
            )
          )
        
        print("STRATA")
        print(unique(InputDataForPlot$Strata))
        print("")
        print("GROUP")
        print(unique(InputDataForPlot$Group))
        
        # if the descriptor is EHR menopause, select the corresponding age
      } else if(currentDescriptor == "EHR_menopauseCode_all_yes") {
        
        # filter to the "age_at_date_conditionehr_menopause_present_289903006_snomed"
        InputDataForPlot <-
          InputDataForPlot %>%
          filter(
            .data = .,
            Strata=="age_at_date_conditionehr_menopause_present_289903006_snomed"
          ) %>%
          filter(
            .data = .,
            grepl(
              pattern = 
                "age_at_date_conditionEHR_Menopause_present_289903006_SNOMED_|none|Education_|ethnicity_|Income_|race_|ancestry_pred_",
              x = Group
            )
          )
        
        # if the descriptor is general demographic data, use those ages
      } else if (currentDescriptor == "Demographic_AoURP_all_yes") {
        
        # filter to the "age at demographic survey data"
        InputDataForPlot <-
          InputDataForPlot %>%
          filter(
            .data = .,
            Strata=="age_at_demographic_survey"
          ) %>%
          filter(
            .data = .,
            grepl(
              pattern = "age_at_demographic_survey_|none|Education_|ethnicity_|Income_|race_|ancestry_pred_",
              x = Group
            )
          )
        
        # otherwise, print a message saying a descriptor that was not accounted for was included 
      } else {
        print("*******UNACCOUNTED FOR DESCRIPTOR INCLUDED IN THIS ANALYSIS********")
      }
      
      
      InputDataForPlot <-
        InputDataForPlot %>%
        # remove any observations with IQR of zero
        filter(
          .data = .,
          IQR > 0
        ) %>%
        # clean up age category labels
        mutate(
          .data = .,
          Group_general = case_when(
            grepl("_q$", Group_general) ~ "age",
            grepl("_mta$", Group_general) ~ "age (MT)",
            TRUE ~ Group_general
          )
        ) 
      
      # make the plot if there is actually data after filtering
      if(nrow(x = InputDataForPlot)>0)
      {
        
        print(currentDescriptor)
        
        # save the data table corresponding to the plot
        InputDataForPlot %>%
          write_tsv(
            x = .,
            file = paste0(
              "./MenoSummaryStats_CUWHC_poster_VERSION8/",
              "ContinuousAgeSummary_Descriptor_allStrataAllgroups_",
              currentDescriptor,
              ".tsv"
            )
          )
        
        # extract colors for each strata level
        strata_levels <-
          InputDataForPlot$Group_general %>%
          unique(x = .) %>%
          sort()
        
        strata_colors <-
          scale_fill_viridis_d()$palette(length(x = strata_levels))
        
        # Create a named vector for easy mapping
        strata_color_map <- setNames(strata_colors, strata_levels)
        
        PlotDesciptorAllStrataGroups <-
          InputDataForPlot %>%
          ggplot(aes(x = Group_specific, fill = Group_general)) +
          geom_boxplot(
            aes(
              lower = Q1,
              middle = median,
              upper = Q3,
              ymin = Q1,
              ymax = Q3
            ),
            stat = "identity",
            position = position_dodge(width = 5),
            width = 0.9,
            color = "black",
            linewidth = 0.7,
            alpha = 0.4
          ) +
          facet_grid(
            Descriptor ~ Group_general,
            scales = "free",
            space = "free_x",
            switch = "x"
          ) +
          scale_y_continuous(
            # labels = scales::comma,
            # breaks = seq(0,500000,5000),
            # expand = c(0,0),
            # limits = c(NA,MaxSampleSizeBuffer),
            name = paste0("Age (years) [Q1, median, Q3]","\n")
          ) +
          scale_fill_viridis_d() +
          guides(fill = "none") +
          labs(
            title = currentDescriptor
          ) +
          theme_classic() +
          theme(
            #plot.title = element_text(hjust = 0.5, size = 7, face = "bold"),
            plot.title = element_blank(),
            axis.title.y = element_text(size = 14, face = "bold"),
            axis.text.y = element_text(face = "bold", size = 14),
            axis.text.x = element_text(angle = 45, hjust = 1,face = "bold",size = 14),
            legend.position = "none",
            legend.background = element_blank(),
            legend.text = element_text(size = 8),
            axis.title.x = element_blank(),
            strip.text.y = element_blank(),
            strip.text.x = element_text(
              face = "bold",colour = "white",size = 14
            ),
            strip.background.x = element_rect(fill = "white"), # placeholder to be modified dynamically
            panel.grid.major.y = element_line(color = "grey", linewidth = 0.2), # Add thin grey horizontal grid lines
            panel.grid.major.x = element_blank(), # Optional: remove vertical grid lines
            panel.grid.minor = element_blank(),    # Remove minor grid lines
            panel.spacing.x = unit(0, "lines"),
            panel.spacing.y = unit(0.25, "lines"),
            plot.margin = margin(0, 0, 0, 0, "cm") # Set plot margins to the smallest possible
          )
        
        # Modify the plot to update strip background colors
        PlotDesciptorAllStrataGroups_colorStrata <- ggplotGrob(PlotDesciptorAllStrataGroups)
        
        # Locate the strip background grobs
        strip_index <- which(grepl("strip-b", PlotDesciptorAllStrataGroups_colorStrata$layout$name))
        
        for (i in strip_index) {
          strip_label <- PlotDesciptorAllStrataGroups_colorStrata$grobs[[i]]$grobs[[1]]$children[[2]]$children[[1]]$label
          PlotDesciptorAllStrataGroups_colorStrata$grobs[[i]]$grobs[[1]]$children[[1]]$gp$fill <- strata_color_map[strip_label]
        }
        
        # Draw the plot
        grid.newpage()
        grid.draw(PlotDesciptorAllStrataGroups_colorStrata)
        
        # save the plot
        ggsave(
          plot = PlotDesciptorAllStrataGroups_colorStrata,
          units = "px",
          path = "./MenoSummaryStats_CUWHC_poster_VERSION8/",
          filename = paste0(
            "ContinuousAgeSummary_Descriptor_allStrataAllgroups_",
            currentDescriptor,
            ".png"
          ),
          width = 5500,
          height = 2750
        )
        
      } else {
        
        currentDescriptor <- NULL
      }
      
      return(currentDescriptor)
    }
  )

Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary %>%
  filter(
    .data = .,
    Descriptor=="EHR_menopauseCode_all_yes" | 
      Descriptor=="Survey_menopauseQuestion_all_yes"
  ) %>%
  filter(
    .data = .,
    Strata=="age_at_date_conditionehr_menopause_present_289903006_snomed" | 
      Strata=="age_at_date_surveyq_overall_health_menstrual_stopped_menstrual_stopped_yes_none"
  ) %>%
  filter(
    .data = .,
    Group=="none"
  ) 

Menopause_demographic_stat_summary_srWGS_EHR_Survey_granular_EHR_and_survey_forSummary$Strata %>%
  unique()
















































































