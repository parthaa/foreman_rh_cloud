import { configureCloudConnector } from '../CloudConnectorActions';

describe('CloudConnector button actions', () => {
  it('should configureCloudConnector', () => {
    const action = configureCloudConnector();
    expect(action).toEqual(
      expect.objectContaining({
        type: 'post-some-type',
        key: 'CONFIGURE_CLOUD_CONNECTOR',
        url: '/foreman_inventory_upload/cloud_connector',
      })
    );
    expect(action.successToast).toBeDefined();
    expect(action.errorToast).toBeDefined();
  });
});
