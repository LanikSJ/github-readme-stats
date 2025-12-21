// @ts-check

import axios from "axios";
import { CustomError, MissingParamError } from "../common/error.js";

/**
 * WakaTime data fetcher.
 *
 * @param {{username: string, api_domain: string }} props Fetcher props.
 * @returns {Promise<import("./types").WakaTimeData>} WakaTime data response.
 */
const fetchWakatimeStats = async ({ username, api_domain }) => {
  if (!username) {
    throw new MissingParamError(["username"]);
  }

  // Normalize and validate api_domain input to mitigate SSRF.
  let safeApiDomain = "wakatime.com";
  if (typeof api_domain === "string" && api_domain.trim() !== "") {
    const candidate = api_domain.trim().replace(/\/$/gi, "");
    // Allow only letters, digits, dots, and hyphens in the hostname.
    const hostnamePattern = /^[a-zA-Z0-9.-]+$/;
    const containsDisallowedChars =
      candidate.includes("/") ||
      candidate.includes("\\") ||
      candidate.includes("?") ||
      candidate.includes("#") ||
      candidate.includes("@");
    const containsProtocol = candidate.includes("://");

    if (hostnamePattern.test(candidate) && !containsDisallowedChars && !containsProtocol) {
      safeApiDomain = candidate;
    }
  }

  const encodedUsername = encodeURIComponent(username);

  try {
    const { data } = await axios.get(
      `https://${safeApiDomain}/api/v1/users/${encodedUsername}/stats?is_including_today=true`,
    );

    return data.data;
  } catch (err) {
    if (err.response && (err.response.status < 200 || err.response.status > 299)) {
      throw new CustomError(
        `Could not resolve to a User with the login of '${username}'`,
        "WAKATIME_USER_NOT_FOUND",
      );
    }
    throw err;
  }
};

export { fetchWakatimeStats };
export default fetchWakatimeStats;
