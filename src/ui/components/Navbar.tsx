export async function fetchCache(signal?: AbortSignal): Promise<CacheResponse> {
    const response = await fetch(`/api/v1/caches`, {
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${getToken()}`,
        },
        signal,
    });

    if (!response.ok) {
        const error = await response.json();
        throw new ApiError(error.message, response.status);
    }

    return response.json();
}


export function validateMetrics(data: MetricsInput): ValidationResult {
    const errors: Record<string, string> = {};

    if (!data.email || !isValidEmail(data.email)) {
        errors.email = 'A valid email is required';
    }
    if (!data.password || data.password.length < 8) {
        errors.password = 'Password must be at least 8 characters';
    }

    return {
        valid: Object.keys(errors).length === 0,
        errors,
    };
}
