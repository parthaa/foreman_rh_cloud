import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import PageHeader from '../PageHeader';

jest.mock('../components/SettingsWarning', () => ({
  __esModule: true,
  default: () => <div data-testid="settings-warning">SettingsWarning</div>,
}));

jest.mock('../PageTitle', () => ({
  __esModule: true,
  default: () => <div data-testid="page-title">PageTitle</div>,
}));

jest.mock('../../InventorySettings', () => ({
  __esModule: true,
  default: () => <div data-testid="inventory-settings">InventorySettings</div>,
}));

jest.mock('../components/PageDescription', () => ({
  __esModule: true,
  default: () => <div data-testid="page-description">PageDescription</div>,
}));

jest.mock('../../InventoryFilter', () => ({
  __esModule: true,
  default: () => <div data-testid="inventory-filter">InventoryFilter</div>,
}));

jest.mock('../components/ToolbarButtons', () => ({
  __esModule: true,
  default: () => <div data-testid="toolbar-buttons">ToolbarButtons</div>,
}));

describe('PageHeader', () => {
  it('should render without props', () => {
    render(<PageHeader />);

    expect(screen.getByTestId('settings-warning')).toBeInTheDocument();
    expect(screen.getByTestId('page-title')).toBeInTheDocument();
    expect(screen.getByTestId('inventory-settings')).toBeInTheDocument();
    expect(screen.getByTestId('page-description')).toBeInTheDocument();
    expect(screen.getByTestId('inventory-filter')).toBeInTheDocument();
    expect(screen.getByTestId('toolbar-buttons')).toBeInTheDocument();
  });
});
