context("Authorization")

test_that("testing missing auth", {
  expect_false(token_available())
  expect_null(sq_access_token())
  expect_false(personal_access_token_available())
  expect_null(sq_personal_access_token())
})

test_that("testing nonsense inputs", {
  expect_error(sq_auth(token = "wrong-path.rds"))
  expect_error(sq_auth(token = letters[1:3]))
})

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
squareupr_token <- readRDS("squareupr_token.rds")

test_that("testing OAuth passing token as filename", {
  sq_auth(token = "squareupr_token.rds")
  expect_true(token_available())
  expect_true(!is.null(sq_access_token()))
})

test_that("testing OAuth passing actual token", {
  sq_auth(token = squareupr_token)
  expect_true(token_available())
  expect_true(!is.null(sq_access_token()))
})

test_that("testing custom token validation routine", {
  res <- sq_auth_check()
  expect_s3_class(res, "Token2.0")
})

test_that("testing PAT auth", {
  personal_access_token <- squareupr_test_settings$personal_access_token
  auth <- sq_auth(personal_access_token = personal_access_token)
  
  expect_is(auth, "list")
  expect_named(auth, c("auth_method", "token", "personal_access_token"))
})

test_that("testing token availability after PAT auth", {
  expect_true(personal_access_token_available())
  expect_true(!is.null(sq_personal_access_token()))
})
