# Use Case Diagram

```mermaid
flowchart LR
  Student["Actor: Siswa"]
  Teacher["Actor: Guru"]
  Admin["Actor: Admin"]
  AI["Actor: AI Service"]
  Notification["Actor: Notification Service"]

  subgraph Auth["Authentication"]
    UC1["Register"]
    UC2["Login"]
    UC3["Verify Email OTP"]
    UC4["Refresh Token"]
    UC5["Logout"]
  end

  subgraph StudentUC["Student Use Cases"]
    UC6["Complete Profile"]
    UC7["Take Diagnostic Assessment"]
    UC8["View AI Profile"]
    UC9["Follow Learning Path"]
    UC10["Open Adaptive Module"]
    UC11["Take Adaptive Quiz"]
    UC12["View Evaluation"]
    UC13["View Learning History"]
    UC14["Manage Settings"]
  end

  subgraph TeacherUC["Teacher Use Cases"]
    UC15["View Teacher Dashboard"]
    UC16["Monitor Classroom Progress"]
    UC17["View Student Detail"]
    UC18["Review Intervention Recommendation"]
    UC19["Track Intervention Outcome"]
  end

  subgraph AdminUC["Admin Use Cases"]
    UC20["Manage Users"]
    UC21["Manage Schools and Classrooms"]
    UC22["Manage Content"]
    UC23["Monitor System"]
  end

  subgraph AIUC["AI Use Cases"]
    UC24["Classify Student Profile with 1D-CNN"]
    UC25["Generate Learning Path"]
    UC26["Update Knowledge State with LSTM-DKT"]
    UC27["Adjust Difficulty with DDA"]
    UC28["Generate Intervention Signals"]
  end

  Student --> UC1
  Student --> UC2
  Student --> UC3
  Student --> UC5
  Student --> UC6
  Student --> UC7
  Student --> UC8
  Student --> UC9
  Student --> UC10
  Student --> UC11
  Student --> UC12
  Student --> UC13
  Student --> UC14

  Teacher --> UC1
  Teacher --> UC2
  Teacher --> UC3
  Teacher --> UC5
  Teacher --> UC15
  Teacher --> UC16
  Teacher --> UC17
  Teacher --> UC18
  Teacher --> UC19

  Admin --> UC20
  Admin --> UC21
  Admin --> UC22
  Admin --> UC23

  AI --> UC24
  AI --> UC25
  AI --> UC26
  AI --> UC27
  AI --> UC28

  UC7 --> UC24
  UC24 --> UC25
  UC11 --> UC26
  UC26 --> UC27
  UC27 --> UC9
  UC26 --> UC28
  UC28 --> UC18
  Notification --> UC14
```

## Use Case Notes

- `Classify Student Profile` harus menyimpan confidence dan model version.
- `Update Knowledge State` berjalan setelah quiz atau checkpoint penting.
- `Adjust Difficulty` tidak boleh memakai satu sinyal saja; minimal mempertimbangkan correctness, response time, mastery probability, dan recent streak.
- `Review Intervention Recommendation` harus menyertakan rationale yang dapat dipahami guru.
