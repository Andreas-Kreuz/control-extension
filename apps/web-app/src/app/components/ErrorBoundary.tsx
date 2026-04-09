import React from 'react';

class ErrorBoundary extends React.Component<{ children?: any }, { hasError: boolean; error: any }> {
  constructor(props: { children: React.ReactNode }, state: { hasError: boolean }) {
    super(props);
    this.state = { hasError: false, error: undefined };
  }

  static getDerivedStateFromError(error: any) {
    return { hasError: true, error: error };
  }

  override componentDidCatch(error: any, errorInfo: any) {
    console.log(error, errorInfo);
  }

  override render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: '2rem' }}>
          <h1>Something went wrong.</h1>
          {this.state.error}
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
