"use client"

import { useState, useEffect } from "react"
import { useParams, useRouter, useSearchParams } from "next/navigation"
import { AppLayout } from "@/components/layout/app-layout"
import { PageContainer } from "@/components/layout/page-container"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Separator } from "@/components/ui/separator"
import { CheckCircle2, XCircle, Clock, Target, TrendingUp, Home, RotateCcw, AlertCircle, FileText, Mic } from "lucide-react"
import { PageLoading } from "@/components/ui/page-loading"
import { EmptyState } from "@/components/ui/empty-state"
import { exercisesApi } from "@/lib/api/exercises"
import { aiApi } from "@/lib/api/ai"
import type { SubmissionResult } from "@/types"
import type { WritingSubmissionResponse, SpeakingSubmissionResponse } from "@/types/ai"
import { usePreferences } from "@/lib/contexts/preferences-context"
import { useTranslations } from '@/lib/i18n'
import { useI18nStore } from '@/lib/i18n/client'

export default function ExerciseResultPage() {
  // Call ALL hooks at top level (before any conditional returns)
  const t = useTranslations('exercises')
  const tAI = useTranslations("ai")
  const params = useParams()
  const router = useRouter()
  const searchParams = useSearchParams()
  const { preferences } = usePreferences()
  const showExplanations = preferences?.show_answer_explanation ?? true // Default to true for backward compatibility
  const exerciseId = params.exerciseId as string
  const submissionId = params.submissionId as string
  const aiSubmissionId = searchParams.get('ai_submission_id') // For AI evaluation submissions

  const [result, setResult] = useState<SubmissionResult | null>(null)
  const [loading, setLoading] = useState(true)
  const [aiEvaluation, setAiEvaluation] = useState<WritingSubmissionResponse | SpeakingSubmissionResponse | null>(null)
  const [loadingAI, setLoadingAI] = useState(false)
  const { locale } = useI18nStore()
  // Use user's locale setting (not a toggle button)
  const feedbackLang = locale === 'vi' ? 'vi' : 'en'

  useEffect(() => {
    const fetchResult = async () => {
      try {
        const data = await exercisesApi.getSubmissionResult(submissionId)
        setResult(data)
      } catch (error: any) {
        // For AI exercises, submission result might not exist (404 is expected)
        // We'll handle it by showing AI evaluation instead
        if (error.response?.status === 404) {
          // 404 is expected for AI exercises (no submission record in exercise service)
          // Silently handle - will show AI evaluation instead
        } else {
          console.error("Failed to fetch result:", error)
        }
      } finally {
        setLoading(false)
      }
    }
    fetchResult()
  }, [submissionId])

  // Fetch AI evaluation if this is an AI exercise (with or without ai_submission_id)
  useEffect(() => {
    let isMounted = true
    
    const fetchAIEvaluation = async () => {
      // If we have ai_submission_id, fetch directly (even without result)
      if (aiSubmissionId) {
        try {
          setLoadingAI(true)
          
          // Try to determine skill type from result or fetch exercise
          let skillType = result?.exercise?.skill_type?.toLowerCase()
          
          if (!skillType && exerciseId) {
            try {
              const exerciseData = await exercisesApi.getExerciseById(exerciseId)
              skillType = exerciseData.exercise.skill_type?.toLowerCase()
            } catch (err) {
              console.error("[Result] Failed to fetch exercise:", err)
              // Default to writing if can't determine
              skillType = "writing"
            }
          }
          
          // Default to writing if still can't determine
          if (!skillType) {
            skillType = "writing"
          }
          
          if (skillType === "writing") {
            const data = await aiApi.getWritingSubmission(aiSubmissionId)
            if (isMounted) setAiEvaluation(data)
          } else if (skillType === "speaking") {
            const data = await aiApi.getSpeakingSubmission(aiSubmissionId)
            if (isMounted) setAiEvaluation(data)
          }
        } catch (error) {
          console.error("Failed to fetch AI evaluation:", error)
        } finally {
          if (isMounted) setLoadingAI(false)
        }
        return
      }

      // Otherwise, check result to determine if it's an AI exercise
      if (!result) return

      const skillType = result.exercise.skill_type?.toLowerCase()
      if (skillType !== "writing" && skillType !== "speaking") return

      // Fallback: Try to find recent AI submission (within last 5 minutes)
      // This helps if URL doesn't have ai_submission_id
      try {
        setLoadingAI(true)
        if (skillType === "writing") {
          const submissions = await aiApi.getWritingSubmissions(5, 0)
          const matchingSubmission = submissions.submissions.find((s) => {
            const submissionTime = new Date(s.created_at).getTime()
            const now = Date.now()
            return (now - submissionTime) < 5 * 60 * 1000 // Within 5 minutes
          })
          if (matchingSubmission && isMounted) {
            const data = await aiApi.getWritingSubmission(matchingSubmission.id)
            if (isMounted) setAiEvaluation(data)
          }
        } else if (skillType === "speaking") {
          const submissions = await aiApi.getSpeakingSubmissions(5, 0)
          const matchingSubmission = submissions.submissions.find((s) => {
            const submissionTime = new Date(s.created_at).getTime()
            const now = Date.now()
            return (now - submissionTime) < 5 * 60 * 1000
          })
          if (matchingSubmission && isMounted) {
            const data = await aiApi.getSpeakingSubmission(matchingSubmission.id)
            if (isMounted) setAiEvaluation(data)
          }
        }
      } catch (error) {
        console.error("Failed to fetch AI evaluation from submissions:", error)
      } finally {
        if (isMounted) setLoadingAI(false)
      }
    }
    
    fetchAIEvaluation()
    
    return () => {
      isMounted = false
    }
  }, [result, aiSubmissionId, exerciseId])

  if (loading && !aiSubmissionId) {
    return (
      <AppLayout>
        <PageContainer>
          <PageLoading translationKey="loading" />
        </PageContainer>
      </AppLayout>
    )
  }

  // If we have AI submission ID, render AI evaluation directly (even without result)
  if (aiSubmissionId) {
    const isWritingExercise = aiEvaluation && 'evaluation' in aiEvaluation && aiEvaluation.evaluation && 'task_achievement_score' in aiEvaluation.evaluation
    const isSpeakingExercise = aiEvaluation && 'evaluation' in aiEvaluation && aiEvaluation.evaluation && 'fluency_coherence_score' in aiEvaluation.evaluation
    
    const writingEval = isWritingExercise ? (aiEvaluation as WritingSubmissionResponse) : null
    const speakingEval = isSpeakingExercise ? (aiEvaluation as SpeakingSubmissionResponse) : null
    
    const writingEvaluation = writingEval?.evaluation
    const speakingEvaluation = speakingEval?.evaluation
    const aiSubmission = writingEval?.submission || speakingEval?.submission

    if (loadingAI) {
      return (
        <AppLayout>
          <PageContainer>
            <PageLoading translationKey="loading" />
          </PageContainer>
        </AppLayout>
      )
    }

    return (
      <AppLayout>
        <PageContainer maxWidth="4xl">
          {/* AI Evaluation Header */}
          <Card className="mb-8">
            <CardHeader className="text-center">
              {writingEvaluation || speakingEvaluation ? (
                <>
                  <div className="flex justify-center mb-4">
                    <CheckCircle2 className="w-16 h-16 text-green-500" />
                  </div>
                  <CardTitle className="text-3xl mb-2">
                    {tAI("evaluation_complete") || "Evaluation Complete"}
                  </CardTitle>
                  <p className="text-muted-foreground">
                    {isWritingExercise 
                      ? (tAI("your_writing_has_been_evaluated") || "Your writing has been evaluated")
                      : (tAI("your_speaking_has_been_evaluated") || "Your speaking has been evaluated")}
                  </p>
                </>
              ) : (
                <>
                  <div className="flex justify-center mb-4">
                    <AlertCircle className="w-16 h-16 text-yellow-500" />
                  </div>
                  <CardTitle className="text-3xl mb-2">
                    {aiSubmission?.status === "processing" || aiSubmission?.status === "transcribing"
                      ? (tAI("processing") || "Processing...")
                      : aiSubmission?.status === "pending"
                      ? (tAI("pending_evaluation") || "Pending Evaluation")
                      : (tAI("evaluation_failed") || "Evaluation Failed")}
                  </CardTitle>
                  <p className="text-muted-foreground">
                    {tAI("please_wait_for_evaluation") || "Please wait while we evaluate..."}
                  </p>
                </>
              )}
            </CardHeader>
            <CardContent>
              {/* Overall Band Score */}
              {(writingEvaluation || speakingEvaluation) && (
                <div className="text-center mb-6">
                  <p className="text-sm text-muted-foreground mb-2">
                    {tAI("overall_band_score") || "Overall Band Score"}
                  </p>
                  <div className="text-6xl font-bold text-primary mb-4">
                    {(writingEvaluation?.overall_band_score || speakingEvaluation?.overall_band_score)?.toFixed(1)}
                  </div>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Criteria Scores */}
          {writingEvaluation && (
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6 mb-8">
              <div className="text-center p-4 bg-blue-50 dark:bg-blue-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{tAI("task_achievement") || "Task Achievement"}</p>
                <p className="text-2xl font-bold text-blue-600">
                  {(writingEvaluation.task_achievement_score ?? writingEvaluation.task_achievement)?.toFixed(1) || tAI("not_available") || "N/A"}
                </p>
              </div>
              <div className="text-center p-4 bg-purple-50 dark:bg-purple-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{tAI("coherence_cohesion") || "Coherence & Cohesion"}</p>
                <p className="text-2xl font-bold text-purple-600">
                  {(writingEvaluation.coherence_cohesion_score ?? writingEvaluation.coherence_cohesion)?.toFixed(1) || tAI("not_available") || "N/A"}
                </p>
              </div>
              <div className="text-center p-4 bg-green-50 dark:bg-green-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{tAI("lexical_resource") || "Lexical Resource"}</p>
                <p className="text-2xl font-bold text-green-600">
                  {(writingEvaluation.lexical_resource_score ?? writingEvaluation.lexical_resource)?.toFixed(1) || tAI("not_available") || "N/A"}
                </p>
              </div>
              <div className="text-center p-4 bg-orange-50 dark:bg-orange-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{tAI("grammatical_range") || "Grammatical Range"}</p>
                <p className="text-2xl font-bold text-orange-600">
                  {(writingEvaluation.grammar_accuracy_score ?? writingEvaluation.grammatical_range)?.toFixed(1) || tAI("not_available") || "N/A"}
                </p>
              </div>
            </div>
          )}

          {speakingEvaluation && (
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6 mb-8">
              <div className="text-center p-4 bg-blue-50 dark:bg-blue-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{tAI("fluency_coherence") || "Fluency & Coherence"}</p>
                <p className="text-2xl font-bold text-blue-600">
                  {(speakingEvaluation.fluency_coherence_score ?? speakingEvaluation.fluency_coherence)?.toFixed(1) || tAI("not_available") || "N/A"}
                </p>
              </div>
              <div className="text-center p-4 bg-green-50 dark:bg-green-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{tAI("lexical_resource") || "Lexical Resource"}</p>
                <p className="text-2xl font-bold text-green-600">
                  {(speakingEvaluation.lexical_resource_score ?? speakingEvaluation.lexical_resource)?.toFixed(1) || tAI("not_available") || "N/A"}
                </p>
              </div>
              <div className="text-center p-4 bg-orange-50 dark:bg-orange-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{tAI("grammatical_range") || "Grammatical Range"}</p>
                <p className="text-2xl font-bold text-orange-600">
                  {(speakingEvaluation.grammar_accuracy_score ?? speakingEvaluation.grammatical_range)?.toFixed(1) || tAI("not_available") || "N/A"}
                </p>
              </div>
              <div className="text-center p-4 bg-purple-50 dark:bg-purple-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{tAI("pronunciation") || "Pronunciation"}</p>
                <p className="text-2xl font-bold text-purple-600">
                  {(speakingEvaluation.pronunciation_score ?? speakingEvaluation.pronunciation)?.toFixed(1) || tAI("not_available") || "N/A"}
                </p>
              </div>
            </div>
          )}

          {/* Submission Content */}
          {writingEval?.submission && (
            <Card className="mb-8">
              <CardHeader>
                <CardTitle>{tAI("your_essay") || "Your Essay"}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="prose prose-sm max-w-none">
                  <p className="whitespace-pre-wrap">{writingEval.submission.essay_text}</p>
                </div>
              </CardContent>
            </Card>
          )}

          {speakingEval?.submission && (
            <Card className="mb-8">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Mic className="w-5 h-5" />
                  {tAI("your_recording") || "Your Recording"}
                </CardTitle>
              </CardHeader>
              <CardContent>
                {speakingEval.submission.audio_url && (
                  <audio src={speakingEval.submission.audio_url} controls className="w-full mb-4" />
                )}
                {(speakingEval.submission.transcript_text || speakingEvaluation?.transcription) && (
                  <div>
                    <h4 className="font-semibold mb-2">{tAI("transcript") || "Transcript"}</h4>
                    <div className="prose prose-sm max-w-none">
                      <p className="whitespace-pre-wrap">{speakingEval.submission.transcript_text || speakingEvaluation?.transcription}</p>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          )}

          {/* Detailed Feedback */}
          {writingEvaluation && (
            <>
              {/* Structured Feedback (if available) */}
              {writingEvaluation.detailed_feedback_json ? (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle>{tAI("detailed_feedback") || "Detailed Feedback"}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-6">
                      {writingEvaluation.detailed_feedback_json.task_achievement && (
                        <div className="border-l-4 border-blue-500 pl-4">
                          <h4 className="font-semibold mb-2 text-lg">{tAI("task_achievement") || "Task Achievement"}</h4>
                          <p className="text-muted-foreground whitespace-pre-wrap">
                            {writingEvaluation.detailed_feedback_json.task_achievement[feedbackLang] || 
                             writingEvaluation.detailed_feedback_json.task_achievement.vi}
                          </p>
                        </div>
                      )}
                      {writingEvaluation.detailed_feedback_json.coherence_cohesion && (
                        <div className="border-l-4 border-purple-500 pl-4">
                          <h4 className="font-semibold mb-2 text-lg">{tAI("coherence_cohesion") || "Coherence & Cohesion"}</h4>
                          <p className="text-muted-foreground whitespace-pre-wrap">
                            {writingEvaluation.detailed_feedback_json.coherence_cohesion[feedbackLang] || 
                             writingEvaluation.detailed_feedback_json.coherence_cohesion.vi}
                          </p>
                        </div>
                      )}
                      {writingEvaluation.detailed_feedback_json.lexical_resource && (
                        <div className="border-l-4 border-green-500 pl-4">
                          <h4 className="font-semibold mb-2 text-lg">{tAI("lexical_resource") || "Lexical Resource"}</h4>
                          <p className="text-muted-foreground whitespace-pre-wrap">
                            {writingEvaluation.detailed_feedback_json.lexical_resource[feedbackLang] || 
                             writingEvaluation.detailed_feedback_json.lexical_resource.vi}
                          </p>
                        </div>
                      )}
                      {writingEvaluation.detailed_feedback_json.grammatical_range && (
                        <div className="border-l-4 border-orange-500 pl-4">
                          <h4 className="font-semibold mb-2 text-lg">{tAI("grammatical_range") || "Grammatical Range"}</h4>
                          <p className="text-muted-foreground whitespace-pre-wrap">
                            {writingEvaluation.detailed_feedback_json.grammatical_range[feedbackLang] || 
                             writingEvaluation.detailed_feedback_json.grammatical_range.vi}
                          </p>
                        </div>
                      )}
                    </div>
                  </CardContent>
                </Card>
              ) : writingEvaluation.detailed_feedback ? (
                // Fallback to plain text if structured feedback not available
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle>{tAI("detailed_feedback") || "Detailed Feedback"}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="prose prose-sm max-w-none">
                      <p className="whitespace-pre-wrap">{writingEvaluation.detailed_feedback}</p>
                    </div>
                  </CardContent>
                </Card>
              ) : null}

              {writingEvaluation.strengths && writingEvaluation.strengths.length > 0 && (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <CheckCircle2 className="w-5 h-5 text-green-500" />
                      {tAI("strengths") || "Strengths"}
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="list-disc list-inside space-y-2">
                      {writingEvaluation.strengths.map((strength, idx) => (
                        <li key={idx}>{strength}</li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              )}

              {(writingEvaluation.areas_for_improvement || writingEvaluation.weaknesses || writingEvaluation.improvement_suggestions) && 
               (writingEvaluation.areas_for_improvement?.length > 0 || writingEvaluation.weaknesses?.length > 0 || writingEvaluation.improvement_suggestions?.length > 0) && (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Target className="w-5 h-5 text-blue-500" />
                      {tAI("areas_for_improvement") || "Areas for Improvement"}
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="list-disc list-inside space-y-2">
                      {(writingEvaluation.areas_for_improvement || writingEvaluation.weaknesses || writingEvaluation.improvement_suggestions || []).map((area, idx) => (
                        <li key={idx}>{area}</li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              )}
            </>
          )}

          {speakingEvaluation && (
            <>
              {speakingEvaluation.examiner_feedback && (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle>{tAI("detailed_feedback") || "Detailed Feedback"}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="prose prose-sm max-w-none">
                      <p className="whitespace-pre-wrap">{speakingEvaluation.examiner_feedback}</p>
                    </div>
                  </CardContent>
                </Card>
              )}

              {speakingEvaluation.strengths && speakingEvaluation.strengths.length > 0 && (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <CheckCircle2 className="w-5 h-5 text-green-500" />
                      {tAI("strengths") || "Strengths"}
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="list-disc list-inside space-y-2">
                      {speakingEvaluation.strengths.map((strength, idx) => (
                        <li key={idx}>{strength}</li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              )}

              {(speakingEvaluation.areas_for_improvement || speakingEvaluation.weaknesses || speakingEvaluation.improvement_suggestions) && 
               (speakingEvaluation.areas_for_improvement?.length > 0 || speakingEvaluation.weaknesses?.length > 0 || speakingEvaluation.improvement_suggestions?.length > 0) && (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Target className="w-5 h-5 text-blue-500" />
                      {tAI("areas_for_improvement") || "Areas for Improvement"}
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="list-disc list-inside space-y-2">
                      {(speakingEvaluation.areas_for_improvement || speakingEvaluation.weaknesses || speakingEvaluation.improvement_suggestions || []).map((area, idx) => (
                        <li key={idx}>{area}</li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              )}
            </>
          )}

          {/* Actions */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button variant="outline" onClick={() => router.push("/exercises/list")}>
              <Home className="w-4 h-4 mr-2" />
              {t('back_to_exercises')}
            </Button>
            {(writingEvaluation || speakingEvaluation) && (
              <Button onClick={() => router.push(`/exercises/${exerciseId}`)}>
                <RotateCcw className="w-4 h-4 mr-2" />
                {t('try_again')}
              </Button>
            )}
          </div>
        </PageContainer>
      </AppLayout>
    )
  }

  if (!result) {
    return (
      <AppLayout>
        <PageContainer>
          <EmptyState
            icon={Target}
            title={t('results_not_found')}
            description={t('results_not_found_description') || "Không tìm thấy kết quả bài tập"}
            actionLabel={t('back_to_exercises') || "Quay lại bài tập"}
            actionOnClick={() => router.push("/exercises/list")}
          />
        </PageContainer>
      </AppLayout>
    )
  }

  const { submission, exercise, answers, performance } = result
  
  // Determine skill type after result is loaded
  const skillType = exercise.skill_type?.toLowerCase()
  const isWritingExercise = skillType === "writing"
  const isSpeakingExercise = skillType === "speaking"
  const isAIExercise = isWritingExercise || isSpeakingExercise

  // Render AI Evaluation Results for Writing/Speaking
  if (isAIExercise) {
    if (loadingAI) {
      return (
        <AppLayout>
          <PageContainer>
            <PageLoading translationKey="loading" />
          </PageContainer>
        </AppLayout>
      )
    }

    if (!aiEvaluation && aiSubmissionId) {
      return (
        <AppLayout>
          <PageContainer>
            <EmptyState
              icon={isWritingExercise ? FileText : Mic}
              title={tAI("evaluation_not_available") || "Evaluation not available"}
              description={tAI("evaluation_not_available_description") || "Đánh giá đang được xử lý hoặc không có sẵn"}
              actionLabel={t('back_to_exercises') || "Back to Exercises"}
              actionOnClick={() => router.push("/exercises/list")}
            />
          </PageContainer>
        </AppLayout>
      )
    }

    const writingEval = isWritingExercise ? (aiEvaluation as WritingSubmissionResponse) : null
    const speakingEval = isSpeakingExercise ? (aiEvaluation as SpeakingSubmissionResponse) : null
    
    const writingEvaluation = writingEval?.evaluation
    const speakingEvaluation = speakingEval?.evaluation
    const aiSubmission = writingEval?.submission || speakingEval?.submission

    return (
      <AppLayout>
        <PageContainer maxWidth="4xl">
          {/* AI Evaluation Header */}
          <Card className="mb-8">
            <CardHeader className="text-center">
              {writingEvaluation || speakingEvaluation ? (
                <>
                  <div className="flex justify-center mb-4">
                    <CheckCircle2 className="w-16 h-16 text-green-500" />
                  </div>
                  <CardTitle className="text-3xl mb-2">
                    {tAI("evaluation_complete") || "Evaluation Complete"}
                  </CardTitle>
                  <p className="text-muted-foreground">
                    {isWritingExercise 
                      ? (tAI("your_writing_has_been_evaluated") || "Your writing has been evaluated")
                      : (tAI("your_speaking_has_been_evaluated") || "Your speaking has been evaluated")}
                  </p>
                </>
              ) : (
                <>
                  <div className="flex justify-center mb-4">
                    <AlertCircle className="w-16 h-16 text-yellow-500" />
                  </div>
                  <CardTitle className="text-3xl mb-2">
                    {aiSubmission?.status === "processing" || aiSubmission?.status === "transcribing"
                      ? (tAI("processing") || "Processing...")
                      : aiSubmission?.status === "pending"
                      ? (tAI("pending_evaluation") || "Pending Evaluation")
                      : (tAI("evaluation_failed") || "Evaluation Failed")}
                  </CardTitle>
                  <p className="text-muted-foreground">
                    {tAI("please_wait_for_evaluation") || "Please wait while we evaluate..."}
                  </p>
                </>
              )}
            </CardHeader>
            <CardContent>
              {/* Overall Band Score */}
              {(writingEvaluation || speakingEvaluation) && (
                <div className="text-center mb-6">
                  <p className="text-sm text-muted-foreground mb-2">
                    {tAI("overall_band_score") || "Overall Band Score"}
                  </p>
                  <div className="text-6xl font-bold text-primary mb-4">
                    {(writingEvaluation?.overall_band_score || speakingEvaluation?.overall_band_score)?.toFixed(1)}
                  </div>
                </div>
              )}

              {/* Criteria Scores */}
              {writingEvaluation && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
                  <div className="text-center p-4 bg-blue-50 dark:bg-blue-950 rounded-lg">
                    <p className="text-xs text-muted-foreground mb-2">{tAI("task_achievement") || "Task Achievement"}</p>
                    <p className="text-2xl font-bold text-blue-600">
                      {(writingEvaluation.task_achievement_score ?? writingEvaluation.task_achievement)?.toFixed(1) || tAI("not_available") || "N/A"}
                    </p>
                  </div>
                  <div className="text-center p-4 bg-purple-50 dark:bg-purple-950 rounded-lg">
                    <p className="text-xs text-muted-foreground mb-2">{tAI("coherence_cohesion") || "Coherence & Cohesion"}</p>
                    <p className="text-2xl font-bold text-purple-600">
                      {(writingEvaluation.coherence_cohesion_score ?? writingEvaluation.coherence_cohesion)?.toFixed(1) || tAI("not_available") || "N/A"}
                    </p>
                  </div>
                  <div className="text-center p-4 bg-green-50 dark:bg-green-950 rounded-lg">
                    <p className="text-xs text-muted-foreground mb-2">{tAI("lexical_resource") || "Lexical Resource"}</p>
                    <p className="text-2xl font-bold text-green-600">
                      {(writingEvaluation.lexical_resource_score ?? writingEvaluation.lexical_resource)?.toFixed(1) || tAI("not_available") || "N/A"}
                    </p>
                  </div>
                  <div className="text-center p-4 bg-orange-50 dark:bg-orange-950 rounded-lg">
                    <p className="text-xs text-muted-foreground mb-2">{tAI("grammatical_range") || "Grammatical Range"}</p>
                    <p className="text-2xl font-bold text-orange-600">
                      {(writingEvaluation.grammar_accuracy_score ?? writingEvaluation.grammatical_range)?.toFixed(1) || tAI("not_available") || "N/A"}
                    </p>
                  </div>
                </div>
              )}

              {speakingEvaluation && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
                  <div className="text-center p-4 bg-blue-50 dark:bg-blue-950 rounded-lg">
                    <p className="text-xs text-muted-foreground mb-2">{tAI("fluency_coherence") || "Fluency & Coherence"}</p>
                    <p className="text-2xl font-bold text-blue-600">
                      {(speakingEvaluation.fluency_coherence_score ?? speakingEvaluation.fluency_coherence)?.toFixed(1) || tAI("not_available") || "N/A"}
                    </p>
                  </div>
                  <div className="text-center p-4 bg-green-50 dark:bg-green-950 rounded-lg">
                    <p className="text-xs text-muted-foreground mb-2">{tAI("lexical_resource") || "Lexical Resource"}</p>
                    <p className="text-2xl font-bold text-green-600">
                      {(speakingEvaluation.lexical_resource_score ?? speakingEvaluation.lexical_resource)?.toFixed(1) || tAI("not_available") || "N/A"}
                    </p>
                  </div>
                  <div className="text-center p-4 bg-orange-50 dark:bg-orange-950 rounded-lg">
                    <p className="text-xs text-muted-foreground mb-2">{tAI("grammatical_range") || "Grammatical Range"}</p>
                    <p className="text-2xl font-bold text-orange-600">
                      {(speakingEvaluation.grammar_accuracy_score ?? speakingEvaluation.grammatical_range)?.toFixed(1) || tAI("not_available") || "N/A"}
                    </p>
                  </div>
                  <div className="text-center p-4 bg-purple-50 dark:bg-purple-950 rounded-lg">
                    <p className="text-xs text-muted-foreground mb-2">{tAI("pronunciation") || "Pronunciation"}</p>
                    <p className="text-2xl font-bold text-purple-600">
                      {(speakingEvaluation.pronunciation_score ?? speakingEvaluation.pronunciation)?.toFixed(1) || tAI("not_available") || "N/A"}
                    </p>
                  </div>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Submission Content */}
          {writingEval?.submission && (
            <Card className="mb-8">
              <CardHeader>
                <CardTitle>{tAI("your_essay") || "Your Essay"}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="prose prose-sm max-w-none">
                  <p className="whitespace-pre-wrap">{writingEval.submission.essay_text}</p>
                </div>
              </CardContent>
            </Card>
          )}

          {speakingEval?.submission && (
            <Card className="mb-8">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Mic className="w-5 h-5" />
                  {tAI("your_recording") || "Your Recording"}
                </CardTitle>
              </CardHeader>
              <CardContent>
                {speakingEval.submission.audio_url && (
                  <audio src={speakingEval.submission.audio_url} controls className="w-full mb-4" />
                )}
                {(speakingEval.submission.transcript_text || speakingEvaluation?.transcription) && (
                  <div>
                    <h4 className="font-semibold mb-2">{tAI("transcript") || "Transcript"}</h4>
                    <div className="prose prose-sm max-w-none">
                      <p className="whitespace-pre-wrap">{speakingEval.submission.transcript_text || speakingEvaluation?.transcription}</p>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          )}

          {/* Detailed Feedback */}
          {writingEvaluation && (
            <>
              {/* Structured Feedback (if available) */}
              {writingEvaluation.detailed_feedback_json ? (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle>{tAI("detailed_feedback") || "Detailed Feedback"}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-6">
                      {writingEvaluation.detailed_feedback_json.task_achievement && (
                        <div className="border-l-4 border-blue-500 pl-4">
                          <h4 className="font-semibold mb-2 text-lg">{tAI("task_achievement") || "Task Achievement"}</h4>
                          <p className="text-muted-foreground whitespace-pre-wrap">
                            {writingEvaluation.detailed_feedback_json.task_achievement[feedbackLang] || 
                             writingEvaluation.detailed_feedback_json.task_achievement.vi}
                          </p>
                        </div>
                      )}
                      {writingEvaluation.detailed_feedback_json.coherence_cohesion && (
                        <div className="border-l-4 border-purple-500 pl-4">
                          <h4 className="font-semibold mb-2 text-lg">{tAI("coherence_cohesion") || "Coherence & Cohesion"}</h4>
                          <p className="text-muted-foreground whitespace-pre-wrap">
                            {writingEvaluation.detailed_feedback_json.coherence_cohesion[feedbackLang] || 
                             writingEvaluation.detailed_feedback_json.coherence_cohesion.vi}
                          </p>
                        </div>
                      )}
                      {writingEvaluation.detailed_feedback_json.lexical_resource && (
                        <div className="border-l-4 border-green-500 pl-4">
                          <h4 className="font-semibold mb-2 text-lg">{tAI("lexical_resource") || "Lexical Resource"}</h4>
                          <p className="text-muted-foreground whitespace-pre-wrap">
                            {writingEvaluation.detailed_feedback_json.lexical_resource[feedbackLang] || 
                             writingEvaluation.detailed_feedback_json.lexical_resource.vi}
                          </p>
                        </div>
                      )}
                      {writingEvaluation.detailed_feedback_json.grammatical_range && (
                        <div className="border-l-4 border-orange-500 pl-4">
                          <h4 className="font-semibold mb-2 text-lg">{tAI("grammatical_range") || "Grammatical Range"}</h4>
                          <p className="text-muted-foreground whitespace-pre-wrap">
                            {writingEvaluation.detailed_feedback_json.grammatical_range[feedbackLang] || 
                             writingEvaluation.detailed_feedback_json.grammatical_range.vi}
                          </p>
                        </div>
                      )}
                    </div>
                  </CardContent>
                </Card>
              ) : writingEvaluation.detailed_feedback ? (
                // Fallback to plain text if structured feedback not available
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle>{tAI("detailed_feedback") || "Detailed Feedback"}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="prose prose-sm max-w-none">
                      <p className="whitespace-pre-wrap">{writingEvaluation.detailed_feedback}</p>
                    </div>
                  </CardContent>
                </Card>
              ) : null}

              {writingEvaluation.strengths && writingEvaluation.strengths.length > 0 && (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <CheckCircle2 className="w-5 h-5 text-green-500" />
                      {tAI("strengths") || "Strengths"}
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="list-disc list-inside space-y-2">
                      {writingEvaluation.strengths.map((strength, idx) => (
                        <li key={idx}>{strength}</li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              )}

              {(writingEvaluation.areas_for_improvement || writingEvaluation.weaknesses || writingEvaluation.improvement_suggestions) && 
               (writingEvaluation.areas_for_improvement?.length > 0 || writingEvaluation.weaknesses?.length > 0 || writingEvaluation.improvement_suggestions?.length > 0) && (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Target className="w-5 h-5 text-blue-500" />
                      {tAI("areas_for_improvement") || "Areas for Improvement"}
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="list-disc list-inside space-y-2">
                      {(writingEvaluation.areas_for_improvement || writingEvaluation.weaknesses || writingEvaluation.improvement_suggestions || []).map((area, idx) => (
                        <li key={idx}>{area}</li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              )}
            </>
          )}

          {speakingEvaluation && (
            <>
              {speakingEvaluation.examiner_feedback && (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle>{tAI("detailed_feedback") || "Detailed Feedback"}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="prose prose-sm max-w-none">
                      <p className="whitespace-pre-wrap">{speakingEvaluation.examiner_feedback}</p>
                    </div>
                  </CardContent>
                </Card>
              )}

              {speakingEvaluation.strengths && speakingEvaluation.strengths.length > 0 && (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <CheckCircle2 className="w-5 h-5 text-green-500" />
                      {tAI("strengths") || "Strengths"}
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="list-disc list-inside space-y-2">
                      {speakingEvaluation.strengths.map((strength, idx) => (
                        <li key={idx}>{strength}</li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              )}

              {(speakingEvaluation.areas_for_improvement || speakingEvaluation.weaknesses || speakingEvaluation.improvement_suggestions) && 
               (speakingEvaluation.areas_for_improvement?.length > 0 || speakingEvaluation.weaknesses?.length > 0 || speakingEvaluation.improvement_suggestions?.length > 0) && (
                <Card className="mb-8">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Target className="w-5 h-5 text-blue-500" />
                      {tAI("areas_for_improvement") || "Areas for Improvement"}
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="list-disc list-inside space-y-2">
                      {(speakingEvaluation.areas_for_improvement || speakingEvaluation.weaknesses || speakingEvaluation.improvement_suggestions || []).map((area, idx) => (
                        <li key={idx}>{area}</li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              )}
            </>
          )}

          {/* Actions */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button variant="outline" onClick={() => router.push("/exercises/list")}>
              <Home className="w-4 h-4 mr-2" />
              {t('back_to_exercises')}
            </Button>
            {(writingEvaluation || speakingEvaluation) && (
              <Button onClick={() => router.push(`/exercises/${exerciseId}`)}>
                <RotateCcw className="w-4 h-4 mr-2" />
                {t('try_again')}
              </Button>
            )}
          </div>
        </PageContainer>
      </AppLayout>
    )
  }

  // Render standard result page for Listening/Reading exercises
  const passed = performance.score >= (exercise.passing_score || 0)
  
  return (
    <AppLayout>
      <PageContainer>
        {/* Result Header */}
        <Card className="mb-8">
          <CardHeader className="text-center">
            <div className="flex justify-center mb-4">
              {passed ? (
                <CheckCircle2 className="w-16 h-16 text-green-500" />
              ) : (
                <XCircle className="w-16 h-16 text-red-500" />
              )}
            </div>
            <CardTitle className="text-3xl mb-2">
              {passed ? t('congratulations') : t('better_luck_next_time')}
            </CardTitle>
            <p className="text-muted-foreground">
              {t('you_scored')} {performance.score.toFixed(1)}% {t('out_of')} {exercise.total_points || 100} {t('points')}
            </p>
          </CardHeader>
          <CardContent>
            <div className="flex justify-center mb-4">
              <Progress value={(performance.score / (exercise.total_points || 100)) * 100} className="w-full max-w-md" />
            </div>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
              <div className="text-center p-4 bg-green-50 dark:bg-green-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{t('correct_answers')}</p>
                <p className="text-2xl font-bold text-green-600">{performance.correct_count}</p>
              </div>
              <div className="text-center p-4 bg-red-50 dark:bg-red-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{t('incorrect_answers')}</p>
                <p className="text-2xl font-bold text-red-600">{performance.incorrect_count}</p>
              </div>
              <div className="text-center p-4 bg-gray-50 dark:bg-gray-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{t('skipped_answers')}</p>
                <p className="text-2xl font-bold text-gray-600">{performance.skipped_count}</p>
              </div>
              <div className="text-center p-4 bg-blue-50 dark:bg-blue-950 rounded-lg">
                <p className="text-xs text-muted-foreground mb-2">{t('time_spent')}</p>
                <p className="text-2xl font-bold text-blue-600">{Math.floor(performance.time_spent_seconds / 60)}m</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Answer Review */}
        {answers && answers.length > 0 && (
          <Card className="mb-8">
            <CardHeader>
              <CardTitle>{t('answer_review')}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {answers.map((answer, idx) => (
                  <div key={idx} className={`p-4 rounded-lg border ${answer.is_correct ? 'bg-green-50 dark:bg-green-950 border-green-200' : 'bg-red-50 dark:bg-red-950 border-red-200'}`}>
                    <div className="flex items-start justify-between mb-2">
                      <Badge variant={answer.is_correct ? "default" : "destructive"}>
                        {answer.is_correct ? t('correct') : t('incorrect')}
                      </Badge>
                      <span className="text-sm text-muted-foreground">{t('question')} {answer.question_number}</span>
                    </div>
                    <p className="font-semibold mb-2">{answer.question_text}</p>
                    <div className="space-y-1 text-sm">
                      <p><span className="font-medium">{t('your_answer')}:</span> {answer.user_answer || t('no_answer')}</p>
                      {!answer.is_correct && answer.correct_answer && (
                        <p><span className="font-medium text-green-600">{t('correct_answer')}:</span> {answer.correct_answer}</p>
                      )}
                      {showExplanations && answer.explanation && (
                        <p className="mt-2 text-muted-foreground">{answer.explanation}</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        )}

        {/* Actions */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Button variant="outline" onClick={() => router.push("/exercises/list")}>
            <Home className="w-4 h-4 mr-2" />
            {t('back_to_exercises')}
          </Button>
          <Button onClick={() => router.push(`/exercises/${exerciseId}`)}>
            <RotateCcw className="w-4 h-4 mr-2" />
            {t('try_again')}
          </Button>
        </div>
      </PageContainer>
    </AppLayout>
  )
}

