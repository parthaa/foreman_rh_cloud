import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ListItem from '../ListItem';
import { props } from '../ListItem.fixtures';

jest.mock('../../../../Dashboard', () => ({
  __esModule: true,
  default: () => <div data-testid="dashboard">Dashboard</div>,
}));

jest.mock('../../../ListItemStatus', () => ({
  __esModule: true,
  default: () => <div data-testid="list-item-status">Status</div>,
}));

describe('ListItem', () => {
  it('should render with props', () => {
    render(<ListItem {...props} />);

    expect(screen.getByText('test')).toBeInTheDocument();
    expect(screen.getByTestId('list-item-status')).toBeInTheDocument();
  });
});
