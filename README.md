# LREC_MulDiLoC-HAP
## MulDiLoC-HAP Corpus Description
MulDiLoC-HAP (Multidialectal, Longitudinal Corpus of Human–AI Hybrid Production) is a large-scale corpus collected to investigate linguistic diversity, dialectal variation, and socio-cognitive dynamics in human–LLM hybrid language production.
The MulDiLoC-HAP corpus was built through a series of controlled experiments conducted with human participants and large language models. The design captures both natural and AI-assisted writing across five major English varieties: British, American, Canadian, Australian, and New Zealand English.
## Core Experimental Design
Participants completed three writing tasks:
1.	Natural Writing Task: Participants wrote a 500-word informal essay on a given topic (e.g., work–life balance) without any assistance.
2.	Machine-Assisted Writing Task: Participants wrote another 500-word essay under one of three LLM-assisted conditions:
o	Grammar and style feedback
o	Incremental suggestions
o	First-half continuation (participants completed an AI-generated opening draft)
3.	Delayed Posttest (Three Weeks Later): Participants wrote a new essay without assistance to examine persistence and transfer effects of AI-assisted writing.
## Corpus and Data Format
All corpus materials are located in the Corpus&Data folder. The main dataset file is MulDiLoC-HAP.csv, which contains all essays and metadata in a single CSV file for ease of access and analysis. We chose this format because it is compatible with Python, R, and most other data analysis environments. This design allows users to extract the specific columns they need without navigating across multiple files, maintaining both simplicity and reproducibility.
The released dataset includes data from 682 participants who consented to share their work publicly. Data from 11 participants who did not provide consent have been excluded from this release.
### CSV File Structure for the Corpus
Please refer to the table below for the meanings of each column in the MulDiLoC-HAP.csv file.
