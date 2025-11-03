# JavaScript & React Coding Standards

**ES6+ and Modern React Best Practices**

[← Back to Index](./README.md)

---

## Quick Reference

**TL;DR:**
- Use ES6+ features (const/let, arrow functions, async/await)
- Functional React components with Hooks
- PropTypes for type checking
- Destructuring for clean code
- Consistent naming conventions
- Comprehensive JSDoc documentation

---

## Table of Contents

1. [ES6+ Standards](#es6-standards)
2. [React Component Structure](#react-component-structure)
3. [Hooks Best Practices](#hooks-best-practices)
4. [State Management](#state-management)
5. [Event Handling](#event-handling)
6. [API Integration](#api-integration)
7. [Code Examples](#code-examples)

---

## ES6+ Standards

### Variable Declarations

```javascript
// ✅ GOOD - Use const/let
const API_URL = 'https://api.compliancescorecard.com';
let counter = 0;
const user = { id: 1, name: 'John' };

// ❌ BAD - Never use var
var oldStyle = 'avoid this';
```

### Arrow Functions

```javascript
// ✅ GOOD - Arrow functions for callbacks
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(n => n * 2);
const filtered = numbers.filter(n => n > 2);

// ✅ GOOD - Arrow functions with multiple params
const sum = (a, b) => a + b;
const calculate = (a, b) => {
    const result = a + b;
    return result * 2;
};

// ✅ GOOD - Arrow functions for event handlers
<button onClick={() => handleClick(item.id)}>
    Click Me
</button>
```

### Template Literals

```javascript
// ✅ GOOD - Template literals
const message = `Welcome ${user.name}!`;
const apiUrl = `${BASE_URL}/api/v3/assessments/${id}`;

// ✅ GOOD - Multi-line strings
const html = `
    <div class="card">
        <h2>${title}</h2>
        <p>${description}</p>
    </div>
`;

// ❌ BAD - String concatenation
const message = 'Welcome ' + user.name + '!';
```

### Destructuring

```javascript
// ✅ GOOD - Object destructuring
const { name, email, company } = user;
const { data, loading, error } = useQuery();

// ✅ GOOD - Array destructuring
const [count, setCount] = useState(0);
const [first, second, ...rest] = items;

// ✅ GOOD - Function parameter destructuring
const UserCard = ({ user, onEdit, onDelete }) => {
    const { name, email } = user;
    // Component logic
};

// ✅ GOOD - Nested destructuring
const { data: { assessment, client } } = response;
```

### Async/Await

```javascript
// ✅ GOOD - Async/await instead of promises
const fetchAssessment = async (id) => {
    try {
        const response = await api.get(`/assessments/${id}`);
        return response.data;
    } catch (error) {
        console.error('Failed to fetch assessment:', error);
        throw error;
    }
};

// ✅ GOOD - Multiple async operations
const loadDashboard = async () => {
    try {
        const [assessments, clients, reports] = await Promise.all([
            fetchAssessments(),
            fetchClients(),
            fetchReports()
        ]);

        setDashboardData({ assessments, clients, reports });
    } catch (error) {
        setError(error.message);
    }
};

// ❌ BAD - Promise chains
fetchAssessment(id)
    .then(data => {
        return processData(data);
    })
    .then(result => {
        setResult(result);
    })
    .catch(error => {
        setError(error);
    });
```

### Optional Chaining & Nullish Coalescing

```javascript
// ✅ GOOD - Optional chaining
const userName = user?.profile?.name;
const firstItem = items?.[0];
const result = api.getData?.();

// ✅ GOOD - Nullish coalescing
const displayName = user.name ?? 'Anonymous';
const pageSize = settings.pageSize ?? 10;

// ❌ BAD - Old null checks
const userName = user && user.profile && user.profile.name;
const displayName = user.name || 'Anonymous';  // May have issues with falsy values
```

---

## React Component Structure

### Functional Component Template

```javascript
// File: src/components/AssessmentCard.jsx

import React, { useState, useEffect, useCallback } from 'react';
import PropTypes from 'prop-types';
import { useNavigate } from 'react-router-dom';
import { Card, Button, Badge } from '../ui';
import { useAuth } from '../hooks/useAuth';
import { assessmentApi } from '../services/api';

/**
 * AssessmentCard Component
 *
 * Displays assessment information with status, progress, and action buttons.
 * Supports real-time updates and handles user permissions.
 *
 * @component
 * @example
 * <AssessmentCard
 *   assessment={assessmentData}
 *   onUpdate={handleUpdate}
 *   showActions={true}
 * />
 */
const AssessmentCard = ({ assessment, onUpdate, showActions = true }) => {
    // ========================================
    // 1. HOOKS
    // ========================================
    const navigate = useNavigate();
    const { user, hasPermission } = useAuth();
    const [loading, setLoading] = useState(false);
    const [progress, setProgress] = useState(0);
    const [error, setError] = useState(null);

    // ========================================
    // 2. EFFECTS
    // ========================================
    useEffect(() => {
        calculateProgress();
    }, [assessment]);

    // ========================================
    // 3. HANDLERS
    // ========================================
    const handleView = useCallback(() => {
        navigate(`/assessments/${assessment.id}`);
    }, [navigate, assessment.id]);

    const handleEdit = useCallback(async () => {
        if (!hasPermission('assessment:edit')) {
            setError('You do not have permission to edit assessments');
            return;
        }

        setLoading(true);
        try {
            await assessmentApi.update(assessment.id, { status: 'editing' });
            onUpdate?.(assessment.id);
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    }, [assessment.id, hasPermission, onUpdate]);

    // ========================================
    // 4. HELPER FUNCTIONS
    // ========================================
    const calculateProgress = () => {
        const totalQuestions = assessment.questions?.length || 0;
        const answeredQuestions = assessment.questions?.filter(q => q.answered).length || 0;
        const percentage = totalQuestions > 0 ? (answeredQuestions / totalQuestions) * 100 : 0;
        setProgress(Math.round(percentage));
    };

    const getStatusColor = (status) => {
        const colors = {
            'completed': 'green',
            'in_progress': 'blue',
            'draft': 'gray',
            'archived': 'red'
        };
        return colors[status] || 'gray';
    };

    // ========================================
    // 5. RENDER
    // ========================================
    return (
        <Card className="assessment-card">
            <div className="card-header">
                <h3>{assessment.name}</h3>
                <Badge color={getStatusColor(assessment.status)}>
                    {assessment.status}
                </Badge>
            </div>

            <div className="card-body">
                <p className="description">{assessment.description}</p>

                <div className="progress-section">
                    <span>Progress: {progress}%</span>
                    <div className="progress-bar">
                        <div
                            className="progress-fill"
                            style={{ width: `${progress}%` }}
                        />
                    </div>
                </div>

                {error && (
                    <div className="error-message">{error}</div>
                )}
            </div>

            {showActions && (
                <div className="card-actions">
                    <Button onClick={handleView} variant="secondary">
                        View
                    </Button>
                    {hasPermission('assessment:edit') && (
                        <Button
                            onClick={handleEdit}
                            variant="primary"
                            disabled={loading}
                        >
                            {loading ? 'Loading...' : 'Edit'}
                        </Button>
                    )}
                </div>
            )}
        </Card>
    );
};

// ========================================
// 6. PROP TYPES
// ========================================
AssessmentCard.propTypes = {
    assessment: PropTypes.shape({
        id: PropTypes.string.isRequired,
        name: PropTypes.string.isRequired,
        description: PropTypes.string,
        status: PropTypes.oneOf(['draft', 'in_progress', 'completed', 'archived']).isRequired,
        questions: PropTypes.arrayOf(PropTypes.shape({
            id: PropTypes.string.isRequired,
            answered: PropTypes.bool
        }))
    }).isRequired,
    onUpdate: PropTypes.func,
    showActions: PropTypes.bool
};

// ========================================
// 7. DEFAULT PROPS
// ========================================
AssessmentCard.defaultProps = {
    onUpdate: null,
    showActions: true
};

export default AssessmentCard;
```

### Component Organization

1. **Imports** - Group by type (React, third-party, local)
2. **Component documentation** - JSDoc comment
3. **Hooks** - useState, useEffect, custom hooks
4. **Effects** - useEffect calls
5. **Handlers** - Event handler functions
6. **Helper Functions** - Pure functions and utilities
7. **Render** - JSX return statement
8. **PropTypes** - Type definitions
9. **Default Props** - Default values

---

## Hooks Best Practices

### useState

```javascript
// ✅ GOOD - Descriptive state names
const [isLoading, setIsLoading] = useState(false);
const [assessments, setAssessments] = useState([]);
const [formData, setFormData] = useState({ name: '', email: '' });

// ✅ GOOD - Functional updates for derived state
const incrementCount = () => {
    setCount(prevCount => prevCount + 1);
};

// ✅ GOOD - Multiple related states in object
const [formState, setFormState] = useState({
    values: {},
    errors: {},
    touched: {},
    isSubmitting: false
});
```

### useEffect

```javascript
// ✅ GOOD - Effect with dependencies
useEffect(() => {
    fetchAssessment(assessmentId);
}, [assessmentId]);

// ✅ GOOD - Cleanup in effect
useEffect(() => {
    const subscription = dataStream.subscribe(data => {
        setData(data);
    });

    return () => {
        subscription.unsubscribe();
    };
}, []);

// ✅ GOOD - Conditional effect
useEffect(() => {
    if (user && user.id) {
        loadUserPreferences(user.id);
    }
}, [user]);

// ❌ BAD - Missing dependencies
useEffect(() => {
    fetchAssessment(assessmentId);  // Missing dependency!
}, []);
```

### useCallback & useMemo

```javascript
// ✅ GOOD - useCallback for event handlers
const handleSubmit = useCallback(async (formData) => {
    setLoading(true);
    try {
        await api.createAssessment(formData);
        onSuccess?.();
    } catch (error) {
        setError(error.message);
    } finally {
        setLoading(false);
    }
}, [onSuccess]);

// ✅ GOOD - useMemo for expensive calculations
const filteredAssessments = useMemo(() => {
    return assessments.filter(a =>
        a.status === filterStatus &&
        a.name.toLowerCase().includes(searchTerm.toLowerCase())
    );
}, [assessments, filterStatus, searchTerm]);

// ✅ GOOD - useMemo for derived data
const statistics = useMemo(() => {
    return {
        total: assessments.length,
        completed: assessments.filter(a => a.status === 'completed').length,
        inProgress: assessments.filter(a => a.status === 'in_progress').length,
        averageScore: calculateAverageScore(assessments)
    };
}, [assessments]);
```

### Custom Hooks

```javascript
// File: src/hooks/useAssessment.js

import { useState, useEffect, useCallback } from 'react';
import { assessmentApi } from '../services/api';

/**
 * Custom hook for assessment management
 *
 * @param {string} assessmentId - The assessment ID
 * @returns {Object} Assessment data and operations
 */
export const useAssessment = (assessmentId) => {
    const [assessment, setAssessment] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchAssessment = useCallback(async () => {
        setLoading(true);
        setError(null);

        try {
            const data = await assessmentApi.get(assessmentId);
            setAssessment(data);
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    }, [assessmentId]);

    const updateAssessment = useCallback(async (updates) => {
        try {
            const updated = await assessmentApi.update(assessmentId, updates);
            setAssessment(updated);
            return updated;
        } catch (err) {
            setError(err.message);
            throw err;
        }
    }, [assessmentId]);

    const deleteAssessment = useCallback(async () => {
        try {
            await assessmentApi.delete(assessmentId);
            setAssessment(null);
        } catch (err) {
            setError(err.message);
            throw err;
        }
    }, [assessmentId]);

    useEffect(() => {
        if (assessmentId) {
            fetchAssessment();
        }
    }, [assessmentId, fetchAssessment]);

    return {
        assessment,
        loading,
        error,
        refresh: fetchAssessment,
        update: updateAssessment,
        delete: deleteAssessment
    };
};
```

---

## State Management

### Context Pattern

```javascript
// File: src/contexts/AssessmentContext.js

import React, { createContext, useContext, useReducer, useCallback } from 'react';

const AssessmentContext = createContext(null);

// Reducer
const assessmentReducer = (state, action) => {
    switch (action.type) {
        case 'SET_ASSESSMENTS':
            return {
                ...state,
                assessments: action.payload,
                loading: false
            };

        case 'ADD_ASSESSMENT':
            return {
                ...state,
                assessments: [...state.assessments, action.payload]
            };

        case 'UPDATE_ASSESSMENT':
            return {
                ...state,
                assessments: state.assessments.map(a =>
                    a.id === action.payload.id ? action.payload : a
                )
            };

        case 'DELETE_ASSESSMENT':
            return {
                ...state,
                assessments: state.assessments.filter(a => a.id !== action.payload)
            };

        case 'SET_LOADING':
            return {
                ...state,
                loading: action.payload
            };

        case 'SET_ERROR':
            return {
                ...state,
                error: action.payload,
                loading: false
            };

        default:
            return state;
    }
};

// Provider
export const AssessmentProvider = ({ children }) => {
    const [state, dispatch] = useReducer(assessmentReducer, {
        assessments: [],
        loading: false,
        error: null
    });

    const setAssessments = useCallback((assessments) => {
        dispatch({ type: 'SET_ASSESSMENTS', payload: assessments });
    }, []);

    const addAssessment = useCallback((assessment) => {
        dispatch({ type: 'ADD_ASSESSMENT', payload: assessment });
    }, []);

    const updateAssessment = useCallback((assessment) => {
        dispatch({ type: 'UPDATE_ASSESSMENT', payload: assessment });
    }, []);

    const deleteAssessment = useCallback((id) => {
        dispatch({ type: 'DELETE_ASSESSMENT', payload: id });
    }, []);

    const value = {
        ...state,
        setAssessments,
        addAssessment,
        updateAssessment,
        deleteAssessment
    };

    return (
        <AssessmentContext.Provider value={value}>
            {children}
        </AssessmentContext.Provider>
    );
};

// Hook
export const useAssessmentContext = () => {
    const context = useContext(AssessmentContext);

    if (!context) {
        throw new Error('useAssessmentContext must be used within AssessmentProvider');
    }

    return context;
};
```

---

## API Integration

### API Service Pattern

```javascript
// File: src/services/assessmentApi.js

import axios from 'axios';
import { getAuthToken } from './auth';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://api.compliancescorecard.com';

// Create axios instance
const apiClient = axios.create({
    baseURL: `${API_BASE_URL}/api/v3`,
    timeout: 10000,
    headers: {
        'Content-Type': 'application/json'
    }
});

// Request interceptor
apiClient.interceptors.request.use(
    (config) => {
        const token = getAuthToken();
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Response interceptor
apiClient.interceptors.response.use(
    (response) => response.data,
    (error) => {
        if (error.response?.status === 401) {
            // Handle unauthorized
            window.location.href = '/login';
        }
        return Promise.reject(error.response?.data || error.message);
    }
);

// Assessment API
export const assessmentApi = {
    /**
     * Get all assessments
     * @param {Object} params - Query parameters
     * @returns {Promise<Array>}
     */
    getAll: async (params = {}) => {
        const response = await apiClient.get('/assessments', { params });
        return response.data;
    },

    /**
     * Get single assessment
     * @param {string} id - Assessment ID
     * @returns {Promise<Object>}
     */
    get: async (id) => {
        const response = await apiClient.get(`/assessments/${id}`);
        return response.data;
    },

    /**
     * Create assessment
     * @param {Object} data - Assessment data
     * @returns {Promise<Object>}
     */
    create: async (data) => {
        const response = await apiClient.post('/assessments', data);
        return response.data;
    },

    /**
     * Update assessment
     * @param {string} id - Assessment ID
     * @param {Object} data - Update data
     * @returns {Promise<Object>}
     */
    update: async (id, data) => {
        const response = await apiClient.put(`/assessments/${id}`, data);
        return response.data;
    },

    /**
     * Delete assessment
     * @param {string} id - Assessment ID
     * @returns {Promise<void>}
     */
    delete: async (id) => {
        await apiClient.delete(`/assessments/${id}`);
    },

    /**
     * Calculate assessment score
     * @param {string} id - Assessment ID
     * @returns {Promise<Object>}
     */
    calculateScore: async (id) => {
        const response = await apiClient.post(`/assessments/${id}/calculate-score`);
        return response.data;
    }
};
```

---

## Related Standards

- [Quality Standards](./08-quality-standards.md)
- [Testing Standards](./10-testing-standards.md)
- [Security Standards](./11-security-standards.md)

---

**Next:** [Database Standards →](./05-database-standards.md)

**Last Updated:** January 2025
