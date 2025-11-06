import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ErrorState from '../ErrorState';

describe('ErrorState', () => {
  it('should render without props', () => {
    render(<ErrorState />);

    expect(screen.getByText('Encountered an error while trying to access the server:')).toBeInTheDocument();
  });
});
