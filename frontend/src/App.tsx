import { AxiosError } from "axios";
import { useState } from "react";
import { PlatformIcon } from "./components/PlatformIcon";
import { repurposeContent } from "./services/api";
import { META_DESCRIPTION_PLATFORM, PLATFORMS } from "./types/index";

interface ErrorState {
  message: string;
  details?: string;
}

function App() {
  const [text, setText] = useState("");
  const [link, setLink] = useState("");
  const [selectedPlatforms, setSelectedPlatforms] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<ErrorState | null>(null);
  const [results, setResults] = useState<Record<string, string> | null>(null);

  const togglePlatform = (platformId: string) => {
    setSelectedPlatforms((prev) =>
      prev.includes(platformId)
        ? prev.filter((id) => id !== platformId)
        : [...prev, platformId]
    );
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setResults(null);

    // Validation
    if (!text.trim()) {
      setError({ message: "Please enter some content to repurpose." });
      return;
    }

    if (selectedPlatforms.length === 0) {
      setError({ message: "Please select at least one platform." });
      return;
    }

    setLoading(true);

    try {
      const response = await repurposeContent({
        text: text.trim(),
        platforms: selectedPlatforms,
        link: link.trim() || undefined,
      });

      setResults(response.posts);
    } catch (err) {
      console.error("Error repurposing content:", err);

      if (err instanceof AxiosError) {
        if (err.response) {
          // Backend returned an error response
          setError({
            message: "Failed to repurpose content",
            details: err.response.data?.detail || err.message,
          });
        } else if (err.request) {
          // Request was made but no response received
          setError({
            message: "Cannot connect to the API server",
            details: "Please ensure the backend is running.",
          });
        } else {
          // Something else happened
          setError({
            message: "An unexpected error occurred",
            details: err.message,
          });
        }
      } else {
        // Non-Axios error
        setError({
          message: "An unexpected error occurred",
          details: err instanceof Error ? err.message : "Unknown error",
        });
      }
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setText("");
    setLink("");
    setSelectedPlatforms([]);
    setResults(null);
    setError(null);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            ✂️ Social Media Repurposer
          </h1>
          <p className="text-lg text-gray-600">
            Transform your long-form content into platform-optimized social
            media posts
          </p>
        </div>

        {/* Main Form */}
        <div className="bg-white rounded-lg shadow-xl p-8 mb-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Link Input */}
            <div>
              <label
                htmlFor="link"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Link (Optional)
              </label>
              <input
                id="link"
                type="text"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                placeholder="https://example.com/your-article"
                value={link}
                onChange={(e) => setLink(e.target.value)}
                disabled={loading}
              />
            </div>

            {/* Content Input */}
            <div>
              <label
                htmlFor="content"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Your Content
              </label>
              <textarea
                id="content"
                rows={8}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent resize-none"
                placeholder="Paste your blog post, article, or any long-form content here..."
                value={text}
                onChange={(e) => setText(e.target.value)}
                disabled={loading}
              />
            </div>

            {/* Platform Selection */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-3">
                Select Platforms
              </label>
              <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
                {PLATFORMS.map((platform) => (
                  <button
                    key={platform.id}
                    type="button"
                    onClick={() => togglePlatform(platform.id)}
                    disabled={loading}
                    className={`
                      flex flex-col items-center justify-center p-4 rounded-lg border-2 transition-all
                      ${
                        selectedPlatforms.includes(platform.id)
                          ? "border-indigo-500 bg-indigo-50"
                          : "border-gray-200 bg-white hover:border-indigo-200"
                      }
                      ${
                        loading
                          ? "opacity-50 cursor-not-allowed"
                          : "cursor-pointer"
                      }
                    `}
                  >
                    <PlatformIcon
                      platform={platform.id}
                      className={`w-8 h-8 mb-2 ${
                        selectedPlatforms.includes(platform.id)
                          ? platform.color
                          : "text-gray-500"
                      }`}
                    />
                    <span className="text-xs font-medium text-center text-gray-700">
                      {platform.name}
                    </span>
                  </button>
                ))}
              </div>
            </div>

            {/* Error Display */}
            {error && (
              <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                <p className="text-red-800 font-medium">{error.message}</p>
                {error.details && (
                  <p className="text-red-600 text-sm mt-1">{error.details}</p>
                )}
              </div>
            )}

            {/* Submit Button */}
            <div className="flex gap-4">
              <button
                type="submit"
                disabled={loading}
                className={`
                  flex-1 py-3 px-6 rounded-lg font-medium text-white transition-all
                  ${
                    loading
                      ? "bg-indigo-400 cursor-not-allowed"
                      : "bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800"
                  }
                `}
              >
                {loading ? (
                  <span className="flex items-center justify-center">
                    <svg
                      className="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                    >
                      <circle
                        className="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        strokeWidth="4"
                      ></circle>
                      <path
                        className="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                      ></path>
                    </svg>
                    Repurposing...
                  </span>
                ) : (
                  "Repurpose Content"
                )}
              </button>

              {(text || link || selectedPlatforms.length > 0 || results) && (
                <button
                  type="button"
                  onClick={handleReset}
                  disabled={loading}
                  className="px-6 py-3 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Reset
                </button>
              )}
            </div>
          </form>
        </div>

        {/* Results Display */}
        {results && (
          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">
              Generated Posts
            </h2>

            {/* Meta-Description - Always shown first */}
            {results["meta-description"] && (
              <div className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow">
                <div className="flex items-center mb-4">
                  <PlatformIcon
                    platform="meta-description"
                    className={`w-8 h-8 mr-3 ${META_DESCRIPTION_PLATFORM.color}`}
                  />
                  <h3 className="text-xl font-semibold text-gray-800">
                    {META_DESCRIPTION_PLATFORM.name}
                  </h3>
                </div>

                <div className="bg-gray-50 rounded-lg p-4">
                  <p className="text-gray-800 whitespace-pre-wrap">
                    {results["meta-description"]}
                  </p>
                </div>

                <div className="mt-4 flex justify-between items-center text-sm text-gray-500">
                  <span>{results["meta-description"].length} characters</span>
                  <button
                    onClick={() => {
                      navigator.clipboard.writeText(results["meta-description"]);
                    }}
                    className="text-indigo-600 hover:text-indigo-700 font-medium"
                  >
                    Copy to Clipboard
                  </button>
                </div>
              </div>
            )}

            {/* Platform Posts - Filter out meta-description */}
            {Object.entries(results)
              .filter(([platform]) => platform !== "meta-description")
              .map(([platform, content]) => {
                const platformInfo = PLATFORMS.find((p) => p.id === platform);

                return (
                  <div
                    key={platform}
                    className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow"
                  >
                    <div className="flex items-center mb-4">
                      <PlatformIcon
                        platform={platform}
                        className={`w-8 h-8 mr-3 ${
                          platformInfo?.color || "text-gray-600"
                        }`}
                      />
                      <h3 className="text-xl font-semibold text-gray-800">
                        {platformInfo?.name || platform}
                      </h3>
                    </div>

                    <div className="bg-gray-50 rounded-lg p-4">
                      <p className="text-gray-800 whitespace-pre-wrap">
                        {content}
                      </p>
                    </div>

                    <div className="mt-4 flex justify-between items-center text-sm text-gray-500">
                      <span>{content.length} characters</span>
                      <button
                        onClick={() => {
                          navigator.clipboard.writeText(content);
                        }}
                        className="text-indigo-600 hover:text-indigo-700 font-medium"
                      >
                        Copy to Clipboard
                      </button>
                    </div>
                  </div>
                );
              })}
          </div>
        )}

        {/* Footer */}
        <div className="mt-12 text-center text-gray-500 text-sm">
          <p>Powered by OpenAI GPT-4 and FastAPI</p>
        </div>
      </div>
    </div>
  );
}

export default App;
