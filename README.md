# LREC_MulDiLoC-HAP
## MulDiLoC-HAP Corpus Description
*MulDiLoC-HAP* (Multidialectal, Longitudinal Corpus of Human–AI Hybrid Production) is a large-scale corpus collected to investigate linguistic diversity, dialectal variation, and socio-cognitive dynamics in human–LLM hybrid language production.
The MulDiLoC-HAP corpus was built through a series of controlled experiments conducted with human participants and GPT 4.1. The design captures both natural and AI-assisted writing across five major English varieties: British, American, Canadian, Australian, and New Zealand English.
## Experimental Design
Participants completed three writing tasks:
1.	Natural Writing Task: Participants wrote a 500-word informal essay on a given topic (e.g., work–life balance) without any assistance.
2.	Machine-Assisted Writing Task: Participants wrote another 500-word essay under one of three LLM-assisted conditions:
o	Grammar and style feedback
o	Incremental suggestions
o	First-half continuation (participants completed an AI-generated opening draft)
3.	Delayed Posttest (Three Weeks Later): Participants wrote a new essay without assistance to examine persistence and transfer effects of AI-assisted writing.
## Corpus and Data Format
All corpus materials are located in the **Corpus&Data** folder. The main dataset file is **MulDiLoC-HAP.csv**, which contains all essays and metadata in a single CSV file for ease of access and analysis. We chose this format because it is compatible with Python, R, and most other data analysis environments. This design allows users to extract the specific columns they need without navigating across multiple files, maintaining both simplicity and reproducibility.
The released dataset includes data from 682 participants who consented to share their work publicly. Data from 11 participants who did not provide consent have been excluded from this release.
### CSV File Structure for the Corpus
Please refer to the table below for the meanings of each column in the **MulDiLoC-HAP.csv** file.

| **Column Name**     | **Description**                                                                                                                                                          |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `ID`                | Unique identifier assigned to each participant                                                                                                                           |
| `Condition`         | Writing condition (Nat = Natural writing; Sty = Stylistic LLM assistance; Phr = Phrasal LLM assistance; Par = Paragraph-level LLM assistance; GPT = GPT-generated texts) |
| `Variety`           | English variety (US = American English; UK = British English; CAN = Canadian English; AUS = Australian English; NZ = New Zealand English)                                |
| `Essay1`            | Essay from the first session                                                                                                                                             |
| `Topic1`            | Topic for the first session                                                                                                                                              |
| `Essay2`            | Essay from the second session                                                                                                                                            |
| `Topic2`            | Topic for the second session                                                                                                                                             |
| `Essay3`            | Essay from the third session                                                                                                                                             |
| `Topic3`            | Topic for the third session                                                                                                                                              |
| `Age`               | Participant’s age                                                                                                                                                        |
| `Gender`            | Participant’s gender                                                                                                                                                     |
| `education_org`     | Original education responses provided by participants                                                                                                                    |
| `education`         | Education responses categorized by the research team                                                                                                                     |
| `occupation`        | Original occupation responses provided by participants                                                                                                                   |
| `ethnicity_org`     | Original ethnicity responses provided by participants                                                                                                                    |
| `ethnicity`         | Ethnicity responses categorized by the research team                                                                                                                     |
| `otherLanguages`    | Bilingualism or multilingualism status                                                                                                                                   |
| `currentLocation`   | Participant’s current country of residence                                                                                                                               |
| `previousLocations` | Locations where participants have lived for more than five years                                                                                                         |
| `aiFamiliarity`     | Familiarity with AI (5-point scale)                                                                                                                                      |
| `aiTools`           | AI tools used in the past three months (from predefined list)                                                                                                            |
| `Otherai`           | Other AI tools used in the past three months (not on the list)                                                                                                           |
| `aiFrequency`       | Frequency of AI use (7-point scale)                                                                                                                                      |
| `aiPurposes`        | Primary purposes for using AI tools                                                                                                                                      |
| `Otheraipurpose`    | Additional purposes of AI use (open-ended responses)                                                                                                                     |
| `aiOpinion`         | Attitudes toward AI (5-point scale)                                                                                                                                      |
| `consent`           | Whether the participant consented to data sharing (Yes/No)                                                                                                               |


### CSV File Structure for the LREC Paper’s Data
Please refer to the table below for the meanings of each column in the **measures.csv** file.

| **Column Name** | **Description** |
|------------------|-----------------|
| `ID` | Unique identifier assigned to each participant |
| `Session` | Experimental session (e.g., 1st = first session, 2nd = second session, 3rd = posttest) |
| `MLTD` | Measure of lexical diversity (Moving-Average Type–Token Ratio) |
| `TotalTokens` | Total number of word tokens in the essay |
| `MeanClauseLength` | Average number of words per clause |
| `AvgDepLength` | Average dependency length per sentence |
| `DepTypeEntropy` | Entropy of dependency relation types (syntactic diversity measure) |
| `NominalDensity` | Proportion of nominal elements (e.g., nouns, noun phrases) in the text |
| `NPComplexity` | Average complexity of noun phrases (e.g., embedded or modified NPs) |
| `VPComplexity` | Average complexity of verb phrases |
| `MeanNPLength` | Mean number of words per noun phrase |
| `PPDensity` | Proportion of prepositional phrases in the text |
| `Condition` | Writing condition (Nat = Natural; Sty = Stylistic LLM assistance; Phr = Phrasal; Par = Paragraph; GPT = General GPT-assisted) |
| `Variety` | English variety (US = American; UK = British; CAN = Canadian; AUS = Australian; NZ = New Zealand) |
| `consent` | Whether the participant consented to data sharing (Yes/No) |
| `Topic` | Topic of the essay |

## Python and R Scripts
