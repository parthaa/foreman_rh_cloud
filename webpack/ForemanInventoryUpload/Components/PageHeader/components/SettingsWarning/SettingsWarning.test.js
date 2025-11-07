import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { SettingsWarning } from './SettingsWarning';

describe('SettingsWarning', () => {
  it('should render with 2 alerts', () => {
    render(
      <SettingsWarning
        autoUpload={false}
        hostObfuscation={true}
        isCloudConnector={true}
      />
    );

    expect(
      screen.getByText(/inventory auto-upload is disabled/i)
    ).toBeInTheDocument();
    expect(
      screen.getByText(/obfuscating host names setting is enabled/i)
    ).toBeInTheDocument();
  });

  it('should render with isCloudConnector false', () => {
    const { container } = render(
      <SettingsWarning
        autoUpload={true}
        hostObfuscation={true}
        isCloudConnector={false}
      />
    );

    // Component returns null when isCloudConnector is false
    expect(container.firstChild).toBeNull();
  });
});
