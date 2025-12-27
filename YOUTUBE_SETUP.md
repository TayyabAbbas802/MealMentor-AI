# YouTube Exercise Videos - Quick Setup Guide

## 🎯 Goal
Add exercise demonstration videos from YouTube to your workout app.

## ✅ What's Done
- ✅ YouTube service created
- ✅ Video player widgets built
- ✅ Exercise model updated
- ✅ WGER integration complete

## 🔑 Setup Required (5 minutes)

### 1. Get YouTube API Key

1. Go to https://console.cloud.google.com
2. Create new project: "MealMentor-AI"
3. Enable "YouTube Data API v3"
4. Create API Key (Credentials → Create → API Key)
5. Copy the key

### 2. Add to .env File

Add this line to your `.env` file:

```
YOUTUBE_API_KEY=YOUR_KEY_HERE
```

### 3. Run

```bash
flutter pub get
flutter run
```

## 📊 Free Tier Limits

- **10,000 requests/day** (very generous!)
- **100 video searches/day**
- **Completely FREE**

## 🎬 How Videos Work

1. **Automatic Search**: App searches YouTube for "{exercise_name} proper form tutorial"
2. **Smart Filtering**: Only short (< 4 min), embeddable videos
3. **Caching**: Video IDs cached to minimize API calls
4. **Pre-caching**: Popular exercises loaded on app start

## 🚀 Next Steps

After setup, you can:

1. **Show video thumbnails** in exercise lists
2. **Play videos** in exercise details
3. **Display during workouts** for reference

## 📝 Example Usage

```dart
// Show video thumbnail
ExerciseVideoThumbnail(
  youtubeVideoId: exercise['youtubeVideoId'],
  exerciseName: exercise['name'],
)

// Full video player
ExerciseVideoPlayer(
  youtubeVideoId: exercise['youtubeVideoId'],
  exerciseName: exercise['name'],
)
```

## 🎉 Benefits

- ✅ HD video tutorials
- ✅ Proper form demonstrations
- ✅ Better user experience
- ✅ Completely free
- ✅ Auto-cached for performance

---

**Ready to add videos to your workout screens!**

See [walkthrough.md](file:///Users/macbookpro/.gemini/antigravity/brain/b86cc650-129f-4656-8dcc-cea555966ec3/walkthrough.md) for detailed documentation.
