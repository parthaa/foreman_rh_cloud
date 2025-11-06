import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import AccountList from '../AccountList';
import { props } from '../AccountList.fixtures';

jest.mock('../Components/ListItem', () => ({
  __esModule: true,
  default: ({ label }) => <div data-testid="list-item">{label}</div>,
}));

jest.mock('../Components/EmptyResults', () => ({
  __esModule: true,
  default: () => <div data-testid="empty-results">No Results</div>,
}));

describe('AccountList', () => {
  it('should render with props', () => {
    render(<AccountList {...props} />);

    const listItems = screen.getAllByTestId('list-item');
    expect(listItems).toHaveLength(3);
    expect(screen.getByText('Account1')).toBeInTheDocument();
    expect(screen.getByText('Account2')).toBeInTheDocument();
    expect(screen.getByText('Account3')).toBeInTheDocument();
  });

  it('should show empty results when filter does not match', () => {
    render(<AccountList {...props} filterTerm="not_matching_term" />);

    expect(screen.getByTestId('empty-results')).toBeInTheDocument();
  });
});
