"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { Loader2, FileText, Mic, Sparkles, CheckCircle2 } from "lucide-react"
import { useTranslations } from '@/lib/i18n'

interface AIEvaluationLoadingProps {
  type: "writing" | "speaking"
  submissionId?: string
  progress?: number
  currentStep?: number
  totalSteps?: number
}

export function AIEvaluationLoading({
  type,
  submissionId,
  progress = 0,
  currentStep = 0,
  totalSteps = 4,
}: AIEvaluationLoadingProps) {
  const t = useTranslations("ai")

  const steps = type === "writing" 
    ? [
        { icon: FileText, text: t("step_submitting") || "Đang gửi bài viết..." },
        { icon: Sparkles, text: t("step_analyzing") || "Đang phân tích bài viết..." },
        { icon: Sparkles, text: t("step_evaluating") || "Đang chấm điểm theo tiêu chí IELTS..." },
        { icon: CheckCircle2, text: t("step_generating_feedback") || "Đang tạo phản hồi chi tiết..." },
      ]
    : [
        { icon: Mic, text: t("step_uploading") || "Đang tải lên file âm thanh..." },
        { icon: Sparkles, text: t("step_transcribing") || "Đang chuyển đổi giọng nói thành văn bản..." },
        { icon: Sparkles, text: t("step_evaluating") || "Đang chấm điểm theo tiêu chí IELTS..." },
        { icon: CheckCircle2, text: t("step_generating_feedback") || "Đang tạo phản hồi chi tiết..." },
      ]

  const currentStepData = steps[currentStep] || steps[0]
  const Icon = currentStepData.icon

  // Calculate overall progress
  const overallProgress = Math.min(
    ((currentStep + 1) / totalSteps) * 100,
    95 // Max 95% while processing
  )

  return (
    <div className="fixed inset-0 bg-background/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <Card className="w-full max-w-2xl shadow-lg">
        <CardHeader className="text-center pb-4">
          <div className="flex justify-center mb-4">
            <div className="relative">
              <Loader2 className="w-16 h-16 animate-spin text-primary" />
              <div className="absolute inset-0 flex items-center justify-center">
                <Icon className="w-8 h-8 text-primary/70" />
              </div>
            </div>
          </div>
          <CardTitle className="text-2xl">
            {type === "writing" 
              ? (t("evaluating_writing") || "Đang chấm điểm bài viết")
              : (t("evaluating_speaking") || "Đang chấm điểm bài nói")
            }
          </CardTitle>
          <p className="text-muted-foreground mt-2">
            {t("please_wait_processing") || "Vui lòng đợi trong khi hệ thống đang xử lý..."}
          </p>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Progress Bar */}
          <div className="space-y-2">
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">
                {currentStepData.text}
              </span>
              <span className="font-medium">
                {Math.round(overallProgress)}%
              </span>
            </div>
            <Progress value={overallProgress} className="h-2" />
          </div>

          {/* Steps List */}
          <div className="space-y-3">
            {steps.map((step, index) => {
              const StepIcon = step.icon
              const isActive = index === currentStep
              const isCompleted = index < currentStep
              
              return (
                <div
                  key={index}
                  className={`flex items-center gap-3 p-3 rounded-lg transition-all ${
                    isActive
                      ? "bg-primary/10 border border-primary/20"
                      : isCompleted
                      ? "bg-green-50 dark:bg-green-950/30 border border-green-200 dark:border-green-800"
                      : "bg-muted/50 border border-transparent"
                  }`}
                >
                  <div className={`flex-shrink-0 ${
                    isActive ? "animate-pulse" : ""
                  }`}>
                    {isCompleted ? (
                      <CheckCircle2 className="w-5 h-5 text-green-600" />
                    ) : (
                      <StepIcon className={`w-5 h-5 ${
                        isActive ? "text-primary" : "text-muted-foreground"
                      }`} />
                    )}
                  </div>
                  <span className={`flex-1 text-sm ${
                    isActive 
                      ? "font-medium text-primary"
                      : isCompleted
                      ? "text-green-700 dark:text-green-400"
                      : "text-muted-foreground"
                  }`}>
                    {step.text}
                  </span>
                  {isActive && (
                    <Loader2 className="w-4 h-4 animate-spin text-primary" />
                  )}
                </div>
              )
            })}
          </div>

          {/* Info Message */}
          <div className="bg-blue-50 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
            <p className="text-sm text-blue-800 dark:text-blue-300 text-center">
              {t("evaluation_takes_time") || "Quá trình chấm điểm có thể mất 30-60 giây. Vui lòng không đóng trang này."}
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

