package main

import (
	"context"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/containerregistry/armcontainerregistry"
	"github.com/cloudnationhq/terraform-azure-acr/shared"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

type ACRDetails struct {
	ResourceGroupName string
	Name              string
}

type ClientSetup struct {
	SubscriptionID  string
	ACRClient       *armcontainerregistry.RegistriesClient
}

func (details *ACRDetails) GetACR(t *testing.T, client *armcontainerregistry.RegistriesClient) *armcontainerregistry.Registry {
	resp, err := client.Get(context.Background(), details.ResourceGroupName, details.Name, nil)
	require.NoError(t, err, "Failed to get registry")
	return &resp.Registry
}

func (setup *ClientSetup) InitializeACRClient(t *testing.T, cred *azidentity.DefaultAzureCredential) {
	var err error
	setup.ACRClient, err = armcontainerregistry.NewRegistriesClient(setup.SubscriptionID, cred, nil)
	require.NoError(t, err, "Failed to initialize client")
}

func TestContainerRegistry(t *testing.T) {
	t.Run("VerifyContainerRegistry", func(t *testing.T) {
		t.Parallel()

		cred, err := azidentity.NewDefaultAzureCredential(nil)
		require.NoError(t, err, "Failed to get credentials")

		tfOpts := shared.GetTerraformOptions("../examples/complete")
		defer shared.Cleanup(t, tfOpts)
		terraform.InitAndApply(t, tfOpts)

		acrMap := terraform.OutputMap(t, tfOpts, "registry")
		subscriptionID := terraform.Output(t, tfOpts, "subscription_id")

		acrDetails := &ACRDetails{
			ResourceGroupName: acrMap["resource_group_name"],
			Name:              acrMap["name"],
		}

		clientSetup := &ClientSetup{SubscriptionID: subscriptionID}
		clientSetup.InitializeACRClient(t, cred)
		registry := acrDetails.GetACR(t, clientSetup.ACRClient)

		t.Run("verifyContainerRegistry", func(t *testing.T) {
			verifyContainerRegistry(t, acrDetails, registry)
		})
	})
}

func verifyContainerRegistry(t *testing.T, details *ACRDetails, registry *armcontainerregistry.Registry) {
	t.Helper()

	require.Equal(
		t,
		details.Name,
		*registry.Name,
		"Registry name does not match expected value",
	)

	require.Equal(
		t,
		"Succeeded",
		string(*registry.Properties.ProvisioningState),
		"Registry provisioning state is not succeeded",
	)

	require.True(
		t,
		strings.HasPrefix(details.Name, "acr"),
		"Registry name does not start with the right abbreviation",
	)
}
