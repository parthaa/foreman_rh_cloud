import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ListItemStatus from '../ListItemStatus';
import { props } from '../ListItemStatus.fixtures';

describe('ListItemStatus', () => {
  it('should render without props', () => {
    render(<ListItemStatus />);

    expect(screen.getByText('Generating')).toBeInTheDocument();
    expect(screen.getByText('Uploading')).toBeInTheDocument();
  });

  it('should render with props', () => {
    render(<ListItemStatus {...props} />);

    expect(screen.getByText('Generating')).toBeInTheDocument();
    expect(screen.getByText('Uploading')).toBeInTheDocument();
  });
});
