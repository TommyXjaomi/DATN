"use client"

import { useTranslations } from "@/lib/i18n"

/**
 * All navigation items hooks
 * Provides translated navigation items for different contexts
 */

export function useNavItems() {
  const t = useTranslations('common')
  
  return [
    {
      title: t('home'),
      href: "/",
      icon: "Home",
    },
    {
      title: t('courses'),
      href: "/courses",
      icon: "BookOpen",
    },
    {
      title: t('exercises'),
      href: "/exercises",
      icon: "PenTool",
    },
    {
      title: t('leaderboard'),
      href: "/leaderboard",
      icon: "Trophy",
    },
  ] as const
}

export function useUserNavItems() {
  const t = useTranslations('common')
  
  return [
    {
      title: t('profile'),
      href: "/profile",
      icon: "User",
    },
    {
      title: t('settings'),
      href: "/settings",
      icon: "Settings",
    },
  ] as const
}

type SidebarNavItem = 
  | {
      title: string
      href: string
      icon: string
      description?: string
    }
  | {
      type: "separator"
      label: string
    }

export function useSidebarNavItems(): SidebarNavItem[] {
  const t = useTranslations('common')
  const tGoals = useTranslations('goals')
  const tReminders = useTranslations('reminders')
  const tAchievements = useTranslations('achievements')
  
  return [
    {
      title: t('dashboard'),
      href: "/dashboard",
      icon: "LayoutDashboard",
    },
    {
      title: t('my_courses') || t('courses'),
      href: "/my-courses",
      icon: "BookOpen",
      description: t('courses_description') || "Manage enrolled courses",
    },
    {
      title: t('my_exercises') || "My Exercises",
      href: "/my-exercises",
      icon: "CheckSquare",
      description: t('manage_your_current_exercises') || "Manage current exercises",
    },
    {
      title: t('my_exercise_history') || "Exercise History",
      href: "/exercises/history",
      icon: "FileText",
      description: t('exercise_history_description') || t('view_full_history') || "Complete archive with search and filters",
    },
    {
      type: "separator",
      label: t('study_tools') || "Study Tools",
    },
    {
      title: tGoals('title'),
      href: "/goals",
      icon: "Target",
    },
    {
      title: tReminders('title'),
      href: "/reminders",
      icon: "Clock",
    },
    {
      title: tAchievements('title'),
      href: "/achievements",
      icon: "Award",
    },
    {
      type: "separator",
      label: t('social') || "Social",
    },
    {
      title: t('leaderboard'),
      href: "/leaderboard",
      icon: "Trophy",
    },
    {
      title: t('notifications'),
      href: "/notifications",
      icon: "Bell",
    },
  ]
}

export function useInstructorNavItems() {
  const t = useTranslations('common')
  
  return [
    {
      title: t('dashboard'),
      href: "/instructor",
      icon: "LayoutDashboard",
    },
    {
      title: t('courses'),
      href: "/instructor/courses",
      icon: "BookOpen",
    },
    {
      title: t('exercises'),
      href: "/instructor/exercises",
      icon: "PenTool",
    },
    {
      title: t('students'),
      href: "/instructor/students",
      icon: "Users",
    },
    {
      title: t('messages'),
      href: "/instructor/messages",
      icon: "MessageSquare",
    },
  ] as const
}

export function useAdminNavItems() {
  const t = useTranslations('common')
  
  return [
    {
      title: t('dashboard'),
      href: "/admin",
      icon: "LayoutDashboard",
      children: [],
    },
    {
      title: t('userManagement'),
      href: "/admin/users",
      icon: "Users",
      children: [],
    },
    {
      title: t('contentManagement'),
      href: "/admin/content",
      icon: "FileText",
      children: [],
    },
    {
      title: t('analytics'),
      href: "/admin/analytics",
      icon: "BarChart",
      children: [],
    },
    {
      title: t('notifications'),
      href: "/admin/notifications",
      icon: "Bell",
      children: [],
    },
    {
      title: t('systemSettings'),
      href: "/admin/settings",
      icon: "Settings",
      children: [],
    },
  ] as const
}
