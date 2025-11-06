import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import EmptyResults from '../EmptyResults';

describe('EmptyResults', () => {
  it('should render without props', () => {
    render(<EmptyResults />);

    expect(screen.getByText("Oops! Couldn't find organization that matches your query")).toBeInTheDocument();
  });
});
