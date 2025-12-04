---
layout: post
title:  "Behavior testing using Mockk"
date:   2024-12-13 20:00:00 +0300
categories: jekyll update
---
Here I’m going to explain how to test behavior of a class through a unit test using [Mockk library](https://mockk.io/) on a very simple example.

MovieDetailViewModel.kt
```kotlin
@HiltViewModel
class MovieDetailViewModel @Inject constructor(
    private val movieService: MovieService,
) : ViewModel() {
    private val _uiModel = MutableStateFlow(MovieDetailUiModel.initial())
    val uiModel get() = _uiModel.asStateFlow()

    fun getMovie(id: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            _uiModel.update { it.copy(isLoading = true) }

            movieService.getMovieDetail(id)
                .toResult()
                .onSuccess { response: MovieDetailResponse ->
                    _uiModel.update {
                        it.copy(isLoading = false, detail = response.toUiModel())
                    }
                }.onFailure {
                    _uiModel.update { it.copy(isLoading = false) }
                }
        }
    }

    private fun MovieDetailResponse.toUiModel(): MovieDetail {
        return MovieDetail(
            image = ImageUtils.getImageUrl(posterPath),
            title = title,
            description = overview ?: ""
        )
    }
}
```

MovieDetailFragment.kt
```kotlin
@AndroidEntryPoint
class MovieDetailFragment : Fragment(R.layout.fragment_movie_detail) {
    private val viewModel: MovieDetailViewModel by viewModels()

    private var _binding: FragmentMovieDetailBinding? = null
    private val binding get() = _binding!!

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        observeUiModel()
        getMovie()
        addOnBackPressedDispatcherCallback()
    }

    private fun getMovie() {
        val movieId = findNavController().currentBackStackEntry
            ?.toRoute<MovieDetailContract.Router.MovieDetailRoute>()!!.id
        viewModel.getMovie(movieId)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentMovieDetailBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    private fun addOnBackPressedDispatcherCallback() {
        requireActivity().onBackPressedDispatcher.addCallback {
            findNavController().navigateUp()
        }
    }

    private fun showLoading() {
        binding.progressBar.visibility = View.VISIBLE
    }

    private fun hideLoading() {
        binding.progressBar.visibility = View.GONE
    }

    private fun observeUiModel() {
        lifecycleScope.launch {
            viewModel.uiModel.collect { uiModel: MovieDetailUiModel ->
                if (uiModel.isLoading) {
                    showLoading()
                } else {
                    hideLoading()
                }

                showMovieDetail(uiModel.detail)
            }
        }
    }

    private fun showMovieDetail(detail: MovieDetail) {
        binding.movieTitle.text = detail.title
        binding.movieDescription.text = detail.description
        binding.moviePoster.load(detail.image)
    }
}
```

MovieService.kt
```kotlin
interface MovieService {

    @GET("movie/{movie_id}")
    suspend fun getMovieDetail(
        @Path("movie_id") movieId: Int
    ): Response<MovieDetailResponse>
}
```

In our example when the fragment is opened, getMovie method in the viewmodel is called and the detail of the movie is fetched and showed on ui.

```kotlin
class MovieDetailViewModelTest {
    @OptIn(ExperimentalCoroutinesApi::class)
    private val testDispatcher = UnconfinedTestDispatcher()
    private val movieService = mockk<MovieService>()
    private val viewModel = MovieDetailViewModel(movieService)

    @Before
    fun before() {
        mockkStatic(Dispatchers::class)
        every { Dispatchers.IO } returns testDispatcher
    }

    @After
    fun after(){
        unmockkStatic(Dispatchers::class)
    }

    @Test
    fun testGetMovie_returnsSuccess_showsCorrectTitle() = runTest {
        val overview = "overview"
        val posterPath = "posterPath"
        val title = "title"
        val fakeMovieDetailResponse = MovieDetailResponse(overview, posterPath, title)

        coEvery {
            movieService.getMovieDetail(movieId = any())
        } returns Response.success(fakeMovieDetailResponse)

        viewModel.getMovie(id = 1)

        Truth.assertThat(viewModel.uiModel.value.detail.title).isEqualTo(title)
    }
}
```

Let’s go line by line
```kotlin
private val testDispatcher = UnconfinedTestDispatcher()
```
This is a dispatcher for tests that can be used in simple tests that concurrency isn’t a big matter as in our test. Otherwise [StandardTestDispatcher](https://developer.android.com/kotlin/coroutines/test#standardtestdispatcher) is suggested to use.

If we use launch method setting a dispatcher like this

```kotlin
fun getMovie(id: Int) {
        viewModelScope.launch(Dispatchers.IO) {
```
and if we don’t handle it in the test, the test will fail. That’s why we use test dispatcher. Therefore, in before method
```kotlin
    @Before
    fun before() {
        mockkStatic(Dispatchers::class)
        every { Dispatchers.IO } returns testDispatcher
    }
```
We use mockkStatic to mock static property IO. It’s going to return testDispatcher throughout the test.

```kotlin
private val movieService = mockk<MovieService>()
```
Here we mock MovieService. It’s not relaxed so Mockk library won’t stub the methods when we don’t define how they answer using every (or coEvery) and it’s going to throw an exception if we try to run the test including a MovieService method we didn’t define it’s answer.

It’s important to not use relaxed mode when the implementation details matter. Actually MovieService is just a retrofit interface that doesn’t include any kind of business logics in its implementation. So it wouldn’t matter as long as we define the answer of MovieService method in our test. But if we injected a repository into our viewmodel and if it had some methods and properties connected to each other then we had to mock the implementation class of the repository without relaxed mode and we had to define every behavior of the repository methods related to the test method for each test to be able to do a proper test.

```kotlin
private val viewModel = MovieDetailViewModel(movieService)
```

Here we create an instance of our viewmodel which is a real object because we want to test behavior.

```kotlin
    @After
    fun after(){
        unmockkStatic(Dispatchers::class)
    }
```
Here we unmock because we might not want same response in our other tests.

```kotlin
    @Test
    fun testGetMovie_returnsSuccess_showsCorrectTitle() = runTest {
        val overview = "overview"
        val posterPath = "posterPath"
        val title = "title"
        val fakeMovieDetailResponse = MovieDetailResponse(overview, posterPath, title)
        val id = 1

        coEvery {
            movieService.getMovieDetail(movieId = id)
        } returns Response.success(fakeMovieDetailResponse)

        viewModel.getMovie(id = id)

        Truth.assertThat(viewModel.uiModel.value.detail.title).isEqualTo(title)
    }
````
Here we create a fake response then we mock getMovieDetail method to make it return a fake response. We use coEvery because it’s a suspend method.

Remember we mock the service response here and we really call viewmodel method.

If we put any() as parameter, It would accept any parameter and return same thing.

```kotlin
        coEvery {
            movieService.getMovieDetail(movieId = any())
        } returns Response.success(fakeMovieDetailResponse)

        viewModel.getMovie(id = 1)
```

Then we assert that title in ui model is same with the title in fake response.

```kotlin
Truth.assertThat(viewModel.uiModel.value.detail.title).isEqualTo(title)
```

So what if we needed to send a log to backend that this user has viewed this movie and we needed to verify that logging method is called. Suppose that we have one more method in viewmodel.

(Of course this wouldn’t be the actual way to log user has viewed a movie but this example is just for the article.)

```kotlin
    fun getMovie(id: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            _uiModel.update { it.copy(isLoading = true) }

            movieService.getMovieDetail(id)
                .toResult()
                .onSuccess { response: MovieDetailResponse ->
                    _uiModel.update {
                        it.copy(isLoading = false, detail = response.toUiModel())
                    }
                    logUserHasViewedMovie(id)
                }.onFailure {
                    _uiModel.update { it.copy(isLoading = false) }
                }
        }
    }

    fun logUserHasViewedMovie(movieId: Int) { }
```

When we use mockk() method, we can alter what a method returns or answers(if it takes a callback, etc.) and we can verify how it’s called(with its parameters). In our example we use a real object(viewmodel). To be able to do verifying and answer altering on real objects we use [spyk()](https://mockk.io/#spy) method.

```kotlin
class MovieDetailViewModelTest {
    @OptIn(ExperimentalCoroutinesApi::class)
    private val testDispatcher = UnconfinedTestDispatcher()
    private val movieService = mockk<MovieService>()
    //We use spyk here.
    private val viewModel = spyk(MovieDetailViewModel(movieService))

    @Before
    fun before() {
        mockkStatic(Dispatchers::class)
        every { Dispatchers.IO } returns testDispatcher
    }

    @After
    fun after() {
        unmockkStatic(Dispatchers::class)
    }


    @Test
    fun testGetMovie_returnsSuccess_showsCorrectTitle() = runTest {
        val overview = "overview"
        val posterPath = "posterPath"
        val title = "title"
        val fakeMovieDetailResponse = MovieDetailResponse(overview, posterPath, title)

        coEvery {
            movieService.getMovieDetail(movieId = 1)
        } returns Response.success(fakeMovieDetailResponse)

        viewModel.getMovie(id = 1)

        Truth.assertThat(viewModel.uiModel.value.detail.title).isEqualTo(title)
    }

    @Test
    fun testGetMovie_returnsSuccess_logsUserHasViewedMovie() = runTest {
        val overview = "overview"
        val posterPath = "posterPath"
        val title = "title"
        val fakeMovieDetailResponse = MovieDetailResponse(overview, posterPath, title)
        val movieId = 1

        coEvery {
            movieService.getMovieDetail(movieId = movieId)
        } returns Response.success(fakeMovieDetailResponse)

        viewModel.getMovie(id = movieId)

        verify {
            viewModel.logUserHasViewedMovie(movieId)
        }
    }
}
```

This way we can see our logging method is called and test is successful.

And if you try to verify with an error response you will see that log method is not called.

```kotlin
    @Test
    fun testGetMovie_fails_doesNotLogUserHasViewedMovie() = runTest {
        val movieId = 1

        mockkStatic("com.mutkuensert.testexample.core.data.ResponseExtKt")
        every { any<ResponseBody>().toException() } returns Exception()

        coEvery {
            movieService.getMovieDetail(movieId = movieId)
        } returns Response.error(404, mockk<ResponseBody>(relaxed = true))

        viewModel.getMovie(id = movieId)

        verify(exactly = 0) {
            viewModel.logUserHasViewedMovie(movieId)
        }

        unmockkStatic("com.mutkuensert.viperexample.core.data.ResponseExtKt")
    }
```

Because I use an extension method toException to convert retrofit Response to [Result](https://github.com/michaelbull/kotlin-result), I had to mock it. That’s also an example [how to mock an extension method](https://mockk.io/#extension-functions).

This was a very simple example and flow but in real word examples as everyone knows features are much more complex and there might be lots of edge cases that we might not see while we’re coding, even when we test it manually. It might look like a bit overhead to write tests but when you get familiar with writing tests it gets a lot faster in time and you’ll love it as you find the edge cases while writing tests.