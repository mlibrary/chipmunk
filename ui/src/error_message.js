const errorMessage = (code, artifact_id) => {
  switch (code) {
    case 404:
      return "We do not have an artifact stored with the identifier: " + artifact_id + ". Please verify that you are using the correct format.";

    case 403:
      return "You are not permitted to view the artifact: " + artifact_id + ". Please contact the content manager for this item if you believe you should have access.";

    default:
      return "We experienced an error in servicing your request. Please try again later.";
  }
}

export default errorMessage;
