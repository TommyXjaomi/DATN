/**
 * Audio Recorder Hook - FREE MediaRecorder API
 * 
 * Features:
 * - ✅ Record audio from microphone
 * - ✅ Pause/Resume recording
 * - ✅ Audio preview
 * - ✅ Upload to MinIO (FREE storage)
 * - ✅ Progress tracking
 * - ✅ Error handling
 */

import { useState, useRef, useCallback } from 'react';

export interface AudioRecorderState {
  isRecording: boolean;
  isPaused: boolean;
  isUploading: boolean;
  recordingTime: number; // seconds
  audioBlob: Blob | null;
  audioURL: string | null;
  uploadProgress: number; // 0-100
  error: string | null;
}

export interface UseAudioRecorderReturn extends AudioRecorderState {
  startRecording: () => Promise<void>;
  pauseRecording: () => void;
  resumeRecording: () => void;
  stopRecording: () => Promise<Blob>;
  uploadAudio: (userId: string, token: string) => Promise<string>; // Returns audio_url
  reset: () => void;
}

export function useAudioRecorder(): UseAudioRecorderReturn {
  const [state, setState] = useState<AudioRecorderState>({
    isRecording: false,
    isPaused: false,
    isUploading: false,
    recordingTime: 0,
    audioBlob: null,
    audioURL: null,
    uploadProgress: 0,
    error: null,
  });

  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const streamRef = useRef<MediaStream | null>(null);

  /**
   * Start recording audio from microphone
   */
  const startRecording = useCallback(async () => {
    try {
      // Request microphone permission
      const stream = await navigator.mediaDevices.getUserMedia({ 
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          sampleRate: 44100,
        } 
      });
      
      streamRef.current = stream;

      // Create MediaRecorder (FREE API)
      const mediaRecorder = new MediaRecorder(stream, {
        mimeType: 'audio/webm', // Most compatible
      });

      mediaRecorderRef.current = mediaRecorder;
      audioChunksRef.current = [];

      // Handle data available event
      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          audioChunksRef.current.push(event.data);
        }
      };

      // Handle stop event
      mediaRecorder.onstop = () => {
        const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
        const audioURL = URL.createObjectURL(audioBlob);
        
        setState(prev => ({
          ...prev,
          audioBlob,
          audioURL,
          isRecording: false,
          isPaused: false,
        }));

        // Stop timer
        if (timerRef.current) {
          clearInterval(timerRef.current);
          timerRef.current = null;
        }

        // Stop all tracks
        if (streamRef.current) {
          streamRef.current.getTracks().forEach(track => track.stop());
          streamRef.current = null;
        }
      };

      // Start recording
      mediaRecorder.start();

      // Start timer
      timerRef.current = setInterval(() => {
        setState(prev => ({
          ...prev,
          recordingTime: prev.recordingTime + 1,
        }));
      }, 1000);

      setState(prev => ({
        ...prev,
        isRecording: true,
        isPaused: false,
        error: null,
        recordingTime: 0,
      }));

    } catch (error) {
      console.error('Failed to start recording:', error);
      setState(prev => ({
        ...prev,
        error: error instanceof Error ? error.message : 'Failed to access microphone',
      }));
    }
  }, []);

  /**
   * Pause recording
   */
  const pauseRecording = useCallback(() => {
    if (mediaRecorderRef.current && state.isRecording && !state.isPaused) {
      mediaRecorderRef.current.pause();
      if (timerRef.current) {
        clearInterval(timerRef.current);
        timerRef.current = null;
      }
      setState(prev => ({ ...prev, isPaused: true }));
    }
  }, [state.isRecording, state.isPaused]);

  /**
   * Resume recording
   */
  const resumeRecording = useCallback(() => {
    if (mediaRecorderRef.current && state.isRecording && state.isPaused) {
      mediaRecorderRef.current.resume();
      
      // Resume timer
      timerRef.current = setInterval(() => {
        setState(prev => ({
          ...prev,
          recordingTime: prev.recordingTime + 1,
        }));
      }, 1000);

      setState(prev => ({ ...prev, isPaused: false }));
    }
  }, [state.isRecording, state.isPaused]);

  /**
   * Stop recording and return audio blob
   */
  const stopRecording = useCallback(async (): Promise<Blob> => {
    return new Promise((resolve, reject) => {
      if (!mediaRecorderRef.current) {
        reject(new Error('No active recording'));
        return;
      }

      mediaRecorderRef.current.onstop = () => {
        const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
        const audioURL = URL.createObjectURL(audioBlob);
        
        setState(prev => ({
          ...prev,
          audioBlob,
          audioURL,
          isRecording: false,
          isPaused: false,
        }));

        // Stop timer
        if (timerRef.current) {
          clearInterval(timerRef.current);
          timerRef.current = null;
        }

        // Stop all tracks
        if (streamRef.current) {
          streamRef.current.getTracks().forEach(track => track.stop());
          streamRef.current = null;
        }

        resolve(audioBlob);
      };

      mediaRecorderRef.current.stop();
    });
  }, []);

  /**
   * Upload audio to MinIO via Storage Service
   */
  const uploadAudio = useCallback(async (userId: string, token: string): Promise<string> => {
    if (!state.audioBlob) {
      throw new Error('No audio to upload');
    }

    setState(prev => ({ ...prev, isUploading: true, uploadProgress: 0, error: null }));

    try {
      // Step 1: Get presigned upload URL
      const uploadUrlResponse = await fetch('/api/v1/storage/audio/upload-url', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({
          file_extension: '.webm',
          content_type: 'audio/webm',
        }),
      });

      if (!uploadUrlResponse.ok) {
        throw new Error('Failed to get upload URL');
      }

      const uploadUrlData = await uploadUrlResponse.json();
      const { upload_url, audio_url } = uploadUrlData.data;

      setState(prev => ({ ...prev, uploadProgress: 30 }));

      // Step 2: Upload audio directly to MinIO
      const uploadResponse = await fetch(upload_url, {
        method: 'PUT',
        body: state.audioBlob,
        headers: {
          'Content-Type': 'audio/webm',
        },
      });

      if (!uploadResponse.ok) {
        throw new Error('Failed to upload audio');
      }

      setState(prev => ({ ...prev, uploadProgress: 100, isUploading: false }));

      // Return audio_url for submission
      return audio_url;

    } catch (error) {
      console.error('Upload failed:', error);
      setState(prev => ({
        ...prev,
        isUploading: false,
        uploadProgress: 0,
        error: error instanceof Error ? error.message : 'Upload failed',
      }));
      throw error;
    }
  }, [state.audioBlob]);

  /**
   * Reset recorder state
   */
  const reset = useCallback(() => {
    // Stop recording if active
    if (mediaRecorderRef.current && state.isRecording) {
      mediaRecorderRef.current.stop();
    }

    // Clear timer
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }

    // Stop media stream
    if (streamRef.current) {
      streamRef.current.getTracks().forEach(track => track.stop());
      streamRef.current = null;
    }

    // Revoke audio URL
    if (state.audioURL) {
      URL.revokeObjectURL(state.audioURL);
    }

    setState({
      isRecording: false,
      isPaused: false,
      isUploading: false,
      recordingTime: 0,
      audioBlob: null,
      audioURL: null,
      uploadProgress: 0,
      error: null,
    });
  }, [state.isRecording, state.audioURL]);

  return {
    ...state,
    startRecording,
    pauseRecording,
    resumeRecording,
    stopRecording,
    uploadAudio,
    reset,
  };
}
