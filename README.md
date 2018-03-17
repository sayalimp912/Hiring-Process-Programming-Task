### Programming Task

#### Overview

Your task is to write a simple script that simulates a hiring process. This script will read a text file `input.txt` as input where each line is a special command, and write responses to another file `output.txt`. In the following sections, we provide you with command descriptions and the expected output.

#### Command Descriptions

- DEFINE:
  - COMMAND: `DEFINE [STAGE_NAMES]`
  - Define the stages in the hiring process. The available stages are `ManualReview PhoneInterview BackgroundCheck DocumentSigning`. The stages can be in any order, and an applicant must be in the last stage in order to be hired.
  - Output: `DEFINE [STAGE_NAMES]`
- CREATE:
  - COMMAND: `CREATE [EMAIL]`
  - Create an applicant with the specified email address. Check if the applicant is already in the system before creating a new one.
  - Output: if the applicant with the same email exists, `Duplicate applicant`. Otherwise, `CREATE [EMAIL]`.
- ADVANCE:
  - COMMAND: `ADVANCE [STAGE_NAME]` or `ADVANCE`
  - Advance the applicant to the specified stage. If `STAGE_NAME` parameter is omitted, advance the applicant to the next stage.
  - Output: if the applicant is already in [STAGE_NAME] or the last stage, `Already in [STAGE_NAME]`. Otherwise, `ADVANCE [STAGE_NAME]`.
- DECIDE:
  - COMMAND: `DECIDE [EMAIL] 1` or `DECIDE [EMAIL] 0`
  - Decide if the applicant should be hired (1) or rejected (0). An applicant can be rejected (0) from any stage, but has to be in the last stage in order to be hired (1).
  - Output: if successfully hired, `Hired [EMAIL]`. If successfully rejected, `Rejected [EMAIL]`. Otherwise, `Failed to decide for [EMAIL]`.
- STATS:
  - COMMAND: `STATS`
  - Print the number of applicants for all stages, including the hired and rejected.
  - Output: [STAGE_1] 0 [STAGE_2] 1 [STAGE_3] 1 Hired 2 Rejected 0

#### EXAMPLES

##### Example 1

input.txt

```
DEFINE ManualReview BackgroundCheck DocumentSigning
STATS
CREATE howon@example.com
ADVANCE howon@example.com
DECIDE howon@example.com 0
STATS
```

output.txt

```
DEFINE ManualReview BackgroundCheck DocumentSigning
ManualReview 0 BackgroundCheck 0 DocumentSigning 0 Hired 0 Rejected 0
CREATE howon@example.com
ADVANCE howon@example.com
Rejected howon@example.com
ManualReview 0 BackgroundCheck 0 DocumentSigning 0 Hired 0 Rejected 1
```

##### EXAMPLE 2

input.txt

```
DEFINE ManualReview BackgroundCheck
CREATE dan@example.com
CREATE paul@example.com
CREATE paul@example.com
ADVANCE paul@example.com
ADVANCE paul@example.com BackgroundCheck
DECIDE paul@example.com 1
DECIDE dan@example.com 1
ADVANCE dan@example.com
DECIDE dan@example.com 1
```

output.txt

```
DEFINE ManualReview BackgroundCheck
CREATE dan@example.com
CREATE paul@example.com
Duplicate applicant
ADVANCE paul@example.com
Already in BackgroundCheck
Hired paul@example.com
Failed to decide for dan@example.com
ADVANCE dan@example.com
Hired dan@example.com
```

#### Submission

When you are done, please zip everything and send it to your point of contact.
We will review your submission and get back to you if there's a good fit!
