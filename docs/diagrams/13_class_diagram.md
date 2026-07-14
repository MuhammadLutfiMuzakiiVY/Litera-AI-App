# Class Diagram

Diagram ini menggambarkan struktur domain inti. Implementasi final dapat memecah class menjadi file berbeda sesuai feature-first architecture.

```mermaid
classDiagram
  class User {
    +String id
    +String email
    +UserRole role
    +bool emailVerified
    +bool profileCompleted
  }

  class StudentProfile {
    +String id
    +String userId
    +String gradeLevel
    +String? schoolId
    +LearningPreference preference
  }

  class TeacherProfile {
    +String id
    +String userId
    +String schoolId
    +SubjectArea subjectArea
  }

  class DiagnosticSession {
    +String id
    +String studentId
    +AssessmentStatus status
    +List~Question~ questions
    +List~Answer~ answers
    +bool canSubmit()
  }

  class DiagnosticResult {
    +String id
    +String sessionId
    +String literacyProfile
    +String numeracyProfile
    +double confidence
    +String modelVersion
  }

  class LearningPath {
    +String id
    +String studentId
    +List~LearningPathItem~ items
    +LearningPathStatus status
    +LearningPathItem nextItem()
  }

  class LearningPathItem {
    +String id
    +String conceptId
    +String moduleId
    +Difficulty targetDifficulty
    +PathItemStatus status
  }

  class Concept {
    +String id
    +String code
    +ConceptDomain domain
    +String name
  }

  class LearningModule {
    +String id
    +String conceptId
    +String title
    +Difficulty difficulty
    +int estimatedMinutes
    +List~ModuleContent~ contents
  }

  class ModuleContent {
    +String id
    +ContentType type
    +int sortOrder
    +Map body
    +String? assetUrl
  }

  class Question {
    +String id
    +String conceptId
    +Difficulty difficulty
    +String stem
    +List~QuestionOption~ options
  }

  class QuestionOption {
    +String id
    +String label
    +String body
  }

  class Answer {
    +String questionId
    +String selectedOptionId
    +int responseTimeMs
    +String idempotencyKey
  }

  class QuizSession {
    +String id
    +String studentId
    +String moduleId
    +Difficulty difficulty
    +List~Question~ questions
    +List~Answer~ answers
    +bool canSubmit()
  }

  class QuizEvaluation {
    +double score
    +List~ConceptMastery~ mastery
    +DdaDecision ddaDecision
  }

  class ConceptMastery {
    +String conceptId
    +double masteryProbability
    +double confidence
    +DateTime updatedAt
  }

  class DdaDecision {
    +Difficulty previousDifficulty
    +Difficulty nextDifficulty
    +String reasonCode
    +String explanation
  }

  class InterventionRecommendation {
    +String id
    +String studentId
    +String conceptId
    +Priority priority
    +String rationale
    +RecommendationStatus status
  }

  class AuthRepository {
    <<interface>>
    +Future~User~ login(email, password)
    +Future~User~ register(request)
    +Future~User~ verifyEmail(otp)
    +Future~void~ logout()
  }

  class AssessmentRepository {
    <<interface>>
    +Future~DiagnosticSession~ startOrResume()
    +Future~void~ saveAnswer(sessionId, answer)
    +Future~DiagnosticResult~ submit(sessionId)
  }

  class LearningRepository {
    <<interface>>
    +Future~LearningPath~ getCurrentPath()
    +Future~LearningModule~ getModule(moduleId)
    +Future~void~ updateProgress(request)
  }

  class QuizRepository {
    <<interface>>
    +Future~QuizSession~ start(moduleId)
    +Future~void~ saveAnswer(quizId, answer)
    +Future~QuizEvaluation~ submit(quizId)
  }

  User "1" --> "0..1" StudentProfile
  User "1" --> "0..1" TeacherProfile
  User "1" --> "0..*" DiagnosticSession
  DiagnosticSession "1" --> "0..*" Answer
  DiagnosticSession "1" --> "1" DiagnosticResult
  DiagnosticResult "1" --> "1" LearningPath
  LearningPath "1" --> "1..*" LearningPathItem
  LearningPathItem "*" --> "1" LearningModule
  LearningModule "*" --> "1" Concept
  LearningModule "1" --> "1..*" ModuleContent
  Question "*" --> "1" Concept
  Question "1" --> "2..*" QuestionOption
  QuizSession "1" --> "0..*" Answer
  QuizSession "1" --> "1" QuizEvaluation
  QuizEvaluation "1" --> "0..*" ConceptMastery
  QuizEvaluation "1" --> "1" DdaDecision
  InterventionRecommendation "*" --> "1" Concept
```

## Implementation Notes

- Domain entities harus immutable di Flutter menggunakan Freezed.
- DTO memakai Json Serializable dan tidak boleh dipakai langsung di UI.
- Entity method hanya boleh berisi logic domain ringan, bukan network/storage.
- Repository contract berada di domain; implementation berada di data.
