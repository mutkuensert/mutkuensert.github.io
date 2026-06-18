---
layout: post
title:  "Encapsulating classes in single module big Android projects"
date:   2026-06-18 17:20:00 +0300
categories: android
excerpt: ""
---

The problem is that name similarities and confusion occur when there are lots of services, screens and classes in a big project within a single module. The right way to separate concerns is a multi module structure for big projects but teams may not have time to convert their projects. To achieve an encapsulation for classes, I’m using [nested classes](https://kotlinlang.org/docs/nested-classes.html). Let me show a simple class:

```kotlin
data class MovieDetailUiModel(
    val id: Int,
    val imagePaths: List<String>,
    val title: String,
    val vote: String,
    val runtime: String,
    val releaseDate: String,
    val overview: String,
    val cast: List<PersonUiModel>,
    val directors: List<CrewPersonUiModel>,
    val writers: List<CrewPersonUiModel>,
    val review: ReviewUiModel?,
) {
    data class CrewPersonUiModel(
        val id: Int,
        val name: String,
    )

    data class PersonUiModel(
        val id: Int,
        val imagePath: String?,
        val name: String,
        val character: String,
    )

    data class ReviewUiModel(
        val id: String,
        val author: String,
        val content: String,
        val editedAt: String,
        val rating: String?,
    )
}
```

The downside of this structure is when you import these nested classes in Android Studio, it will automatically import the classes like this:

```kotlin
fun Person.toUiModel(): MovieDetailUiModel.PersonUiModel {
    return MovieDetailUiModel.PersonUiModel(
        id = id,
        imagePath = imagePath,
        name = name,
        character = character ?: ""
    )
}
```

But we can add the import by hand:

```kotlin
import feature.movie.domain.model.Person
import feature.movie.presentation.detail.model.MovieDetailUiModel.PersonUiModel

fun Person.toUiModel(): PersonUiModel {
    return PersonUiModel(
        id = id,
        imagePath = imagePath,
        name = name,
        character = character ?: ""
    )
}
```

Thus, when there is another PersonUiModel with different contents in another screen, it will be easy to distinguish the classes because we will know where they belong by looking at their outer classes.