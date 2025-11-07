import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { CloudConnectorButton } from '../CloudConnectorButton';
import { CONNECTOR_STATUS } from '../CloudConnectorConstants';

describe('CloudConnectorButton', () => {
  it('should render no cloud connector', () => {
    render(
      <CloudConnectorButton
        status={CONNECTOR_STATUS.NOT_RESOLVED}
        onClick={jest.fn()}
      />
    );

    expect(screen.getByText('Configure cloud connector')).toBeInTheDocument();
  });

  it('should render resolved cloud connector', () => {
    render(
      <CloudConnectorButton
        status={CONNECTOR_STATUS.RESOLVED}
        onClick={jest.fn()}
      />
    );

    expect(screen.getByText('Reconfigure cloud connector')).toBeInTheDocument();
  });

  it('should render pending connector', () => {
    render(
      <CloudConnectorButton
        jobLink="/job-link"
        status={CONNECTOR_STATUS.PENDING}
        onClick={jest.fn()}
      />
    );

    expect(screen.getByText('Cloud Connector is in progress')).toBeInTheDocument();
    // The button should be disabled when status is PENDING
    const button = screen.getByRole('button');
    expect(button).toBeDisabled();
  });
});
