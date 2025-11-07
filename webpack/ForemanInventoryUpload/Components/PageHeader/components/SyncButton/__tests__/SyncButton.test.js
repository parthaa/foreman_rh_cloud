import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { noop } from 'foremanReact/common/helpers';
import SyncButton from '../SyncButton';

describe('SyncButton', () => {
  it('should render with props', () => {
    render(<SyncButton handleSync={noop} />);

    expect(screen.getByText('Sync all inventory status')).toBeInTheDocument();
  });
});
