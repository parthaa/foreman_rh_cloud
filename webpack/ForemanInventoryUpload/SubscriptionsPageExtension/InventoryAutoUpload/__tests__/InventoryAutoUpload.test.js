import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { noop } from 'foremanReact/common/helpers';

import InventoryAutoUpload from '../InventoryAutoUpload';

describe('InventoryAutoUpload', () => {
  describe('rendering', () => {
    it('should render with props', () => {
      render(
        <InventoryAutoUpload
          autoUploadEnabled={true}
          setSetting={noop}
          getSettings={noop}
        />
      );
      expect(screen.getByRole('checkbox')).toBeInTheDocument();
    });
  });
});
