import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import EmptyState from '../EmptyState';

describe('EmptyState', () => {
  it('should render without props', () => {
    render(<EmptyState />);

    expect(screen.getByText('Fetching data about your accounts')).toBeInTheDocument();
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });
});
