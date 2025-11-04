"use client"

import { AppLayout } from "@/components/layout/app-layout"
import { PageContainer } from "@/components/layout/page-container"
import { PageHeader } from "@/components/layout/page-header"
import { ProtectedRoute } from "@/components/auth/protected-route"
import { useTranslations } from "@/lib/i18n"
import { PageLoading } from "@/components/ui/page-loading"
import { lazy, Suspense } from "react"

// Lazy load heavy component to improve initial load time
const AchievementsList = lazy(() => import("@/components/achievements/achievements-list").then(m => ({ default: m.AchievementsList })))

export default function AchievementsPage() {
  return (
    <ProtectedRoute>
      <AchievementsContent />
    </ProtectedRoute>
  )
}

function AchievementsContent() {
  const t = useTranslations('achievements')

  return (
    <AppLayout showSidebar={true} showFooter={false} hideNavbar={true} hideTopBar={true}>
      <PageHeader
        title={t('title')}
        subtitle={t('subtitle')}
      />
      <PageContainer>
        {/* Achievements List */}
        <Suspense fallback={<PageLoading translationKey="loading_achievements" />}>
          <AchievementsList />
        </Suspense>
      </PageContainer>
    </AppLayout>
  )
}

