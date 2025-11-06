/**
 * Audio Recorder Component - FREE Recording UI
 * 
 * Usage:
 * ```tsx
 * <AudioRecorder 
 *   onAudioReady={(audioUrl) => console.log('Ready:', audioUrl)}
 *   maxDuration={180} // 3 minutes
 * />
 * ```
 */

'use client';

import React, { useEffect } from 'react';
import { useAudioRecorder } from '@/hooks/useAudioRecorder';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { Mic, Square, Pause, Play, Upload, RotateCcw } from 'lucide-react';

interface AudioRecorderProps {
  onAudioReady?: (audioUrl: string) => void;
  maxDuration?: number; // seconds (default: 180 = 3 minutes)
  userId: string;
  token: string;
}

export function AudioRecorder({ 
  onAudioReady, 
  maxDuration = 180,
  userId,
  token 
}: AudioRecorderProps) {
  const {
    isRecording,
    isPaused,
    isUploading,
    recordingTime,
    audioBlob,
    audioURL,
    uploadProgress,
    error,
    startRecording,
    pauseRecording,
    resumeRecording,
    stopRecording,
    uploadAudio,
    reset,
  } = useAudioRecorder();

  // Auto-stop when max duration reached
  useEffect(() => {
    if (isRecording && recordingTime >= maxDuration) {
      stopRecording();
    }
  }, [isRecording, recordingTime, maxDuration, stopRecording]);

  const handleUpload = async () => {
    try {
      const audioUrl = await uploadAudio(userId, token);
      onAudioReady?.(audioUrl);
    } catch (error) {
      console.error('Upload failed:', error);
    }
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="space-y-4 p-6 border rounded-lg bg-card">
      {/* Recording Status */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold">
            {isRecording ? '🔴 Recording' : audioBlob ? '✅ Recording Complete' : '🎤 Ready to Record'}
          </h3>
          <p className="text-sm text-muted-foreground">
            {isRecording 
              ? `${formatTime(recordingTime)} / ${formatTime(maxDuration)}`
              : audioBlob
              ? `Duration: ${formatTime(recordingTime)}`
              : 'Click record to start'
            }
          </p>
        </div>

        {/* Recording Timer Progress */}
        {isRecording && (
          <div className="text-2xl font-mono font-bold text-red-500">
            {formatTime(recordingTime)}
          </div>
        )}
      </div>

      {/* Progress Bar for Duration */}
      {isRecording && (
        <Progress value={(recordingTime / maxDuration) * 100} className="h-2" />
      )}

      {/* Control Buttons */}
      <div className="flex gap-2 flex-wrap">
        {!isRecording && !audioBlob && (
          <Button onClick={startRecording} size="lg" className="gap-2">
            <Mic className="w-5 h-5" />
            Start Recording
          </Button>
        )}

        {isRecording && !isPaused && (
          <>
            <Button onClick={pauseRecording} variant="outline" size="lg" className="gap-2">
              <Pause className="w-5 h-5" />
              Pause
            </Button>
            <Button onClick={stopRecording} variant="destructive" size="lg" className="gap-2">
              <Square className="w-5 h-5" />
              Stop
            </Button>
          </>
        )}

        {isRecording && isPaused && (
          <>
            <Button onClick={resumeRecording} size="lg" className="gap-2">
              <Play className="w-5 h-5" />
              Resume
            </Button>
            <Button onClick={stopRecording} variant="destructive" size="lg" className="gap-2">
              <Square className="w-5 h-5" />
              Stop
            </Button>
          </>
        )}

        {audioBlob && !isUploading && (
          <>
            <Button onClick={handleUpload} size="lg" className="gap-2">
              <Upload className="w-5 h-5" />
              Upload & Submit
            </Button>
            <Button onClick={reset} variant="outline" size="lg" className="gap-2">
              <RotateCcw className="w-5 h-5" />
              Re-record
            </Button>
          </>
        )}
      </div>

      {/* Audio Preview */}
      {audioURL && !isUploading && (
        <div className="space-y-2">
          <p className="text-sm font-medium">Preview:</p>
          <audio controls src={audioURL} className="w-full" />
        </div>
      )}

      {/* Upload Progress */}
      {isUploading && (
        <div className="space-y-2">
          <div className="flex items-center justify-between text-sm">
            <span>Uploading...</span>
            <span>{uploadProgress}%</span>
          </div>
          <Progress value={uploadProgress} />
        </div>
      )}

      {/* Error Message */}
      {error && (
        <div className="p-3 bg-destructive/10 text-destructive rounded-md text-sm">
          ⚠️ {error}
        </div>
      )}

      {/* Instructions */}
      {!isRecording && !audioBlob && (
        <div className="text-xs text-muted-foreground space-y-1">
          <p>📝 Tips:</p>
          <ul className="list-disc list-inside space-y-1 pl-2">
            <li>Ensure you have a working microphone</li>
            <li>Speak clearly and at a normal pace</li>
            <li>Minimum recording time: 10 seconds</li>
            <li>Maximum recording time: {Math.floor(maxDuration / 60)} minutes</li>
          </ul>
        </div>
      )}
    </div>
  );
}
