import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { noop } from 'foremanReact/common/helpers';
import InventoryFilter from '../InventoryFilter';
import { filterTerm } from '../InventoryFilter.fixtures';

jest.mock('foremanReact/Root/Context/ForemanContext', () => ({
  useForemanOrganization: () => ({ title: 'some-org' }),
}));

jest.mock('../Components/ClearButton', () => ({
  __esModule: true,
  default: () => <button data-testid="clear-button">Clear</button>,
}));

describe('InventoryFilter', () => {
  it('should render with props', () => {
    render(
      <InventoryFilter
        handleFilterChange={noop}
        handleFilterClear={noop}
        filterTerm={filterTerm}
      />
    );

    const input = screen.getByPlaceholderText('Filter..');
    expect(input).toBeInTheDocument();
    expect(input).toHaveValue('test_filter_term');
    expect(screen.getByTestId('clear-button')).toBeInTheDocument();
  });
});
