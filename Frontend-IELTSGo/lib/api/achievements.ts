import { apiClient } from "./apiClient"
import { apiCache } from "@/lib/utils/api-cache"

interface ApiResponse<T> {
  success: boolean
  message?: string
  data: T
  error?: {
    code: string
    message: string
  }
}

export interface Achievement {
  id: number
  code: string
  name: string
  description?: string
  criteria_type: string
  criteria_value: number
  icon_url?: string
  badge_color?: string
  points: number
  created_at: string
}

// Backend returns AchievementWithProgress structure
export interface AchievementWithProgress {
  achievement: Achievement
  is_earned: boolean
  earned_at?: string
  progress: number
  progress_percentage: number
}

export interface UserAchievement {
  id: number
  user_id: string
  achievement: Achievement
  earned_at: string
  // Or flat structure
  achievement_id?: number
  achievement_name?: string
  achievement_description?: string
  earned_at_flat?: string
}

export interface AchievementsResponse {
  achievements?: Achievement[]
  count?: number
}

export const achievementsApi = {
  // Get all available achievements
  getAllAchievements: async (): Promise<Achievement[]> => {
    const cacheKey = apiCache.generateKey('/user/achievements')
    
    // Check cache first
    const cached = apiCache.get<Achievement[]>(cacheKey)
    if (cached) {
      return cached
    }

    const response = await apiClient.get<ApiResponse<AchievementsResponse | AchievementWithProgress[]>>("/user/achievements")
    const data = response.data.data
    
    // Backend returns {achievements: AchievementWithProgress[], count: number}
    let result: Achievement[] = []
    if (data && typeof data === 'object' && 'achievements' in data) {
      const achievementsWithProgress = (data as AchievementsResponse).achievements as AchievementWithProgress[]
      // Flatten: extract achievement from AchievementWithProgress
      result = achievementsWithProgress.map(item => 
        'achievement' in item ? item.achievement : item as unknown as Achievement
      )
    } else if (Array.isArray(data)) {
      // Handle array response (if backend returns array directly)
      result = data.map(item => 
        'achievement' in item ? item.achievement : item as unknown as Achievement
      )
    }
    
    // Cache for 60 seconds (achievements don't change frequently)
    apiCache.set(cacheKey, result, 60000)
    return result
  },

  // Get earned achievements
  getEarnedAchievements: async (): Promise<UserAchievement[]> => {
    const cacheKey = apiCache.generateKey('/user/achievements/earned')
    
    // Check cache first
    const cached = apiCache.get<UserAchievement[]>(cacheKey)
    if (cached) {
      return cached
    }

    const response = await apiClient.get<ApiResponse<UserAchievement[] | AchievementsResponse>>("/user/achievements/earned")
    const data = response.data.data
    
    // Handle different response structures
    let result: UserAchievement[] = []
    if (Array.isArray(data)) {
      result = data
    } else if (data && typeof data === 'object' && 'achievements' in data) {
      // Handle {achievements: [], count: number}
      result = (data as AchievementsResponse).achievements as UserAchievement[] || []
    }
    
    // Cache for 60 seconds (earned achievements don't change frequently)
    apiCache.set(cacheKey, result, 60000)
    return result
  },
}

