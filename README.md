# Code in Ecology

This repository contains the data, code and other materials used in the following study:

Antica Culina*, Ilona van den Berg, Simon Evans, Alfredo Sánchez-Tójar*. *Submitted*. **Low availability of code in ecology: a call for urgent action.**

The supplementary information is available at: [supplementary information](https://asanchez-tojar.github.io/code_in_ecology/supporting_information.html)

For any further information about the **code**, please contact: [Alfredo Sánchez-Tójar](https://scholar.google.co.uk/citations?hl=en&user=Sh-Rjq8AAAAJ&view_op=list_works&sortby=pubdate), email: alfredo.tojar@gmail.com. 

For any further information about the **data, materials or more generally, the study**, please contact [Antica Culina](https://scholar.google.com/citations?hl=en&user=9dgJnxEAAAAJ&view_op=list_works&sortby=pubdate), email: A.Culina@nioo.knaw.nl; and/or [Alfredo Sánchez-Tójar](https://scholar.google.co.uk/citations?hl=en&user=Sh-Rjq8AAAAJ&view_op=list_works&sortby=pubdate), email: alfredo.tojar@gmail.com.

## Information about scripts, folders and files within:

[`data`](https://github.com/ASanchez-Tojar/code_in_ecology/tree/master/data): contains the data used in the study. Specifically, it contains five files: 
  - `Code_policies.docx`: word document listing the journals with code-sharing policies in March 2020 (more in [supplementary information](https://asanchez-tojar.github.io/code_in_ecology/supporting_information.html)), a copy-paste of the information provided in the author guidelines/journal policies section of each journal, and a link to the section.
  - `Data_Feb_2020_V8.xlsx`: excel document with three sheets containing the data extracted during the review process, including the data regarding those articles that were double-checked by a second observer: (i) Dataset_2015_16: data for the 2015-2016 period (extracted by AC, double-checked by AST); (ii) Dataset_2018_19: data for the 2018-2019 period (extracted by AST, double-checked by AC); and (iii) explanations: metadata provided information about the variables extracted in the first two sheets. 
  - `Updated_Table_Mislan_2020_v2.xlsx`: excel sheet containing data about the type of code-sharing policies of each of the 96 journals reviewed in March 2020. The list of journals is based on that compiled by [Mislan et al. 2016](https://doi.org/10.1016/j.tree.2015.11.006).
  - `code_availability_full_and_clean.csv`: this is the **final dataset** used for the analyses conducted in this study, and this dataset is the output of the script [`003_data_cleaning_and_standardization.R`](https://github.com/ASanchez-Tojar/code_in_ecology/blob/master/003_data_cleaning_and_standardization.R), which imports the file `Updated_Table_Mislan_2020_v2.xlsx`, cleans it, and create new variables for the analyses.
  - `journal_info_v2.csv`: small dataset containing the code-sharing policy and name abbrevation of each of the 14 journals from which we calculated code-sharing practices. Note that the code-sharing policy of this journals is also available in the file `Updated_Table_Mislan_2020_v2.xlsx`.

[`docs`](https://github.com/ASanchez-Tojar/code_in_ecology/tree/master/docs): contains the supplementary information file of this study. To visualize the html file, click [**here**](https://asanchez-tojar.github.io/code_in_ecology/supporting_information.html). 

[`plots`](https://github.com/ASanchez-Tojar/code_in_ecology/tree/master/plots): contains all three figures from this study. Figure 1 and 2 correspond to those included in the main manuscript, and Figure S1 is included in the supplementary information.

[`screening_process`](https://github.com/ASanchez-Tojar/code_in_ecology/tree/master/screening_process): contains data for reproducing the literature search of 2018-2019. For the literature search of 2015-2016, no code was used (except the function `sample()` for ramdonly selecting articles, which was used for both years (code not available). This folder contains two subfolders:
**1.** [`title-and-abstract_screening`](https://github.com/ASanchez-Tojar/code_in_ecology/tree/master/screening_process/title-and-abstract_screening): containing multiple files used for the title-and-abstract screening performed in [Rayyan](https://rayyan.qcri.org/).
  - `random_200_2018_2019.bib`: all 200 references reviewed for 2018-2019 in .bib format.
  - `random_200_2018_2019_rayyan.csv`: all 200 references reviewed for 2018-2019 in .csv format, with only the necessary information (variables) for importing into the title-and-abstract screening software ([Rayyan](https://rayyan.qcri.org/)). This file is the output of the script [`001_title-and-abstract_screening.R`](https://github.com/ASanchez-Tojar/code_in_ecology/blob/master/001_title-and-abstract_screening.R).
  - `random_200_2018_2019_rayyan_edited.csv`: same file as `random_200_2018_2019_rayyan.csv` after removing some quotation marks manually so that it can be imported into the title-and-abstract screening software ([Rayyan](https://rayyan.qcri.org/)). 
  - `rayyan_csv_example.csv`: template with the variables needed for importing into the the title-and-abstract screening software ([Rayyan](https://rayyan.qcri.org/)).
  - `screening_process_Rpackages_session.txt`: information about the R session (e.g. versions and packages used) used when running the script [`001_title-and-abstract_screening.R`](https://github.com/ASanchez-Tojar/code_in_ecology/blob/master/001_title-and-abstract_screening.R).
**2.** [`fulltext_screening`](https://github.com/ASanchez-Tojar/code_in_ecology/tree/master/screening_process/fulltext_screening): containing multiple files used for the fulltext screening:
  - `instructions/Code_evaluation_template_v2.xlsx`: excel file used as template for choosing what variables to add.
  - `fulltext_screening_process_Rpackages_session.txt`: information about the R session (e.g. versions and packages used) used when running the script [`002_fulltext_screening.R`](https://github.com/ASanchez-Tojar/code_in_ecology/blob/master/002_fulltext_screening.R).
  - `random_200_2018_2019_rayyan_edited_t-and-a_decisions.csv`: .csv file extracted from [Rayyan](https://rayyan.qcri.org/) and containing the title-and-abstract decisions taken during the screening.

### Notes:

See details of the licence of this repository in [LICENSE.txt](https://github.com/ASanchez-Tojar/meta-analysis_transgenerational_effects_commentary/blob/master/LICENSE.txt)
