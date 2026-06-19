---
layout: post
title:  "Encapsulating classes in large single module Android projects"
date:   2026-06-19 07:00:00 +0300
categories: android
excerpt: ""
---

The problem is that name similarities and confusion occur when there are lots of services, screens and classes in a large project within a single module. The right way to separate concerns is a multi module structure but teams may not have time to convert their projects. To achieve an encapsulation for classes, I’m using [nested classes](https://kotlinlang.org/docs/nested-classes.html). For example:

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
import feature.movie.domain.model.Person

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

Thus, when another screen has a `PersonUiModel` with different contents, it will be easy to distinguish the classes because their outer classes indicate where they belong. This approach can also be used for response classes, etc.